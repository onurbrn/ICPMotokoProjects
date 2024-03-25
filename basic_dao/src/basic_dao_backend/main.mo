import Trie "mo:base/Trie"; // veri yapısı anahtar ve değer çifti saklar
import Error "mo:base/Error"; // hata durumu, genelde metin türlerde ayrıntıları içerir
import Result "mo:base/Result"; // işlemin sonucunu temsil eder, başarılı ise #ok, başarısız ise #err
import Nat "mo:base/Nat";
import Iter "mo:base/Iter"; // koleksiyonun elemanları üzerinde dolaşan döngü
import Option "mo:base/Option"; // bir varlığı veya yokluğu temsil ediyor
import Principal "mo:base/Principal"; // dfinity'nin Internet Computer ağında kullanıcısı, id'ler benzersiz
import ICRaw "mo:base/ExperimentalInternetComputer"; // bir canister çağırmak için, ana ağa bağlanmıyoruz, deneysel bir canister çağırıyoruz
import Time "mo:base/Time"; // zaman, geçerli zamanı almak, zaman aralıklarını ölçmek
import List "mo:base/List"; // elemanları üzerinde dolaşılabilen bir koleksiyon
import Types "./Types"; // ayrı motoko dosyası, kodun daha düzenli ve okunabilir olmasını sağlıyor

// her cüzdanın bir oylama hakkı var

shared actor class DAO(init : Types.BasicDaoStableStorage) = Self {
    stable var accounts = Types.accounts_fromArray(init.accounts);
    stable var proposals = Types.proposals_fromArray(init.proposals);
    stable var next_proposal_id : Nat = 0;
    stable var system_params : Types.SystemParams = init.system_params;

    system func heartbeat() : async () {
        await execute_accepted_proposals();
    };

    func account_get(id : Principal) : ?Types.Tokens = Trie.get(accounts, Types.account_key(id), Principal.equal);
    func account_put(id : Principal, tokens : Types.Tokens) {
        accounts := Trie.put(accounts, Types.account_key(id), Principal.equal, tokens).0;
    };
    func proposal_get(id : Nat) : ?Types.Proposal = Trie.get(proposals, Types.proposal_key(id), Nat.equal);
    func proposal_put(id : Nat, proposal : Types.Proposal) {
        proposals := Trie.put(proposals, Types.proposal_key(id), Nat.equal, proposal).0;
    };

    /// Çağrı sahibinin hesabından başka bir hesaba token aktarır
    public shared({caller}) func transfer(transfer: Types.TransferArgs) : async Types.Result<(), Text> {
        switch (account_get caller) {
        case null { #err "Çağrı sahibinin fon aktarmak için bir hesabı olmalıdır" };
        case (?from_tokens) {
                 let fee = system_params.transfer_fee.amount_e8s;
                 let amount = transfer.amount.amount_e8s;
                 if (from_tokens.amount_e8s < amount + fee) {
                     #err ("Çağrı sahibinin hesabında yetersiz fon var: " # debug_show(amount));
                 } else {
                     let from_amount : Nat = from_tokens.amount_e8s - amount - fee;
                     account_put(caller, { amount_e8s = from_amount });
                     let to_amount = Option.get(account_get(transfer.to), Types.zeroToken).amount_e8s + amount;
                     account_put(transfer.to, { amount_e8s = to_amount });
                     #ok;
                 };
        };
      };

    /// Çağrı sahibinin hesabının bakiyesini döndürür //??? ders kaydından sonra hataya tekrar bak ??
    public query({caller}) func account_balance() : async Types.Tokens {
        Option.get(account_get(caller), Types.zeroToken)
    };

    /// Tüm hesapları listeler
    public query func list_accounts() : async [Types.Account] {
        Iter.toArray(
          Iter.map(Trie.iter(accounts),
                   func ((owner : Principal, tokens : Types.Tokens)) : Types.Account = { owner; tokens }))
    };

    /// Bir öneri gönderir
    ///
    /// Bir öneri bir canister kimliği, yöntem adı ve yöntem argümanlarını içerir. Eğer yeterli sayıda
    /// kullanıcı öneriye "evet" oyu verirse, verilen yöntem ve argümanlar belirtilen canister üzerinde
    /// çağrılır.
    public shared({caller}) func submit_proposal(payload: Types.ProposalPayload) : async Types.Result<Nat, Text> {
        Result.chain(deduct_proposal_submission_deposit(caller), func (()) : Types.Result<Nat, Text> {
            let proposal_id = next_proposal_id;
            next_proposal_id += 1;

            let proposal : Types.Proposal = {
                id = proposal_id;
                votes_no = Types.zeroToken;
                votes_yes = Types.zeroToken;
                voters = [];
                state = #open;
                timestamp = Time.now();
                proposer = caller;
                payload = payload;
            };
            proposal_put(proposal_id, proposal);
            #ok(proposal_id)
        })
    };

    /// Açık bir öneriye oy verir
    public shared({caller}) func vote(args: Types.VoteArgs) : async Types.Result<Types.ProposalState, Text> {
        switch (proposal_get(args.proposal_id)) {
        case null { #err("ID'si " # debug_show(args.proposal_id) # " olan bir öneri bulunamadı") };
        case (?proposal) {
                 var state = proposal.state;
                 if (state != #open) {
                     return #err("Öneri " # debug_show(args.proposal_id) # " oylamaya açık değil");
                 };
                 switch (account_get(caller)) {
                 case null { return #err("Çağrı sahibinin oy vermek için herhangi bir jetonu yok") };
                 case (?{ amount_e8s = voting_tokens }) {
                          if (List.some(proposal.voters, func (e : Principal) : Bool = e
== caller)) {
                              return #err("Zaten oy kullandınız");
                          };
                          
                          var votes_yes = proposal.votes_yes.amount_e8s;
                          var votes_no = proposal.votes_no.amount_e8s;
                          switch (args.vote) {
                          case (#yes) { votes_yes += voting_tokens };
                          case (#no) { votes_no += voting_tokens };
                          };
                          let voters = List.push(caller, proposal.voters);

                          if (votes_yes >= system_params.proposal_vote_threshold.amount_e8s) {
                              // Öneri kabul edildiğinde öneri yatırımını iade et
                              ignore do ? {
                                  let account = account_get(proposal.proposer)!;
                                  let refunded = account.amount_e8s + system_params.proposal_submission_deposit.amount_e8s;
                                  account_put(proposal.proposer, { amount_e8s = refunded });
                              };
                              state := #accepted;
                          };
                          
                          if (votes_no >= system_params.proposal_vote_threshold.amount_e8s) {
                              state := #rejected;
                          };

                          let updated_proposal = {
                              id = proposal.id;
                              votes_yes = { amount_e8s = votes_yes };                              
                              votes_no = { amount_e8s = votes_no };
                              voters;
                              state;
                              timestamp = proposal.timestamp;
                              proposer = proposal.proposer;
                              payload = proposal.payload;
                          };
                          proposal_put(args.proposal_id, updated_proposal);
                          #ok(state)
                      };
                 };
             };
        };
    };

    /// Mevcut sistem parametrelerini alır
    public query func get_system_params() : async Types.SystemParams {
        system_params
    };

    /// Sistem parametrelerini günceller
    ///
    /// Sadece öneri yürütme yoluyla çağrılabilir
    public shared({caller}) func update_system_params(payload: Types.UpdateSystemParamsPayload) : async () {
        if (caller != Principal.fromActor(Self)) {
            return;
        };
        system_params := {
            transfer_fee = Option.get(payload.transfer_fee, system_params.transfer_fee);
            proposal_vote_threshold = Option.get(payload.proposal_vote_threshold, system_params.proposal_vote_threshold);
            proposal_submission_deposit = Option.get(payload.proposal_submission_deposit, system_params.proposal_submission_deposit);
        };
    };

    /// Öneri yatırımını çağrı sahibinin hesabından düşer
    func deduct_proposal_submission_deposit(caller : Principal) : Types.Result<(), Text> {
        switch (account_get(caller)) {
        case null { #err "Öneri göndermek için çağrı sahibinin bir hesabı olmalıdır" };
        case (?from_tokens) {
                 let threshold = system_params.proposal_submission_deposit.amount_e8s;
                 if (from_tokens.amount_e8s < threshold) {
                     #err ("Çağrı sahibinin hesabında en az " # debug_show(threshold) # " olmalıdır, öneri göndermek için")
                 } else {
                     let from_amount : Nat = from_tokens.amount_e8s - threshold;
                     account_put(caller, { amount_e8s = from_amount });
                     #ok
                 };
             };
        };
    };

    /// Kabul edilen tüm önerileri yürütür
    func execute_accepted_proposals() : async () {
        let accepted_proposals = Trie.filter(proposals, func (_ : Nat, proposal : Types.Proposal) : Bool = proposal.state == #accepted);
        // Öneri durumunu güncelle, böylece bir sonraki kalp atışında seçilmez
        for ((id, proposal) in Trie.iter(accepted_proposals)) {
            update_proposal_state(proposal, #executing);
        };

        for ((id, proposal) in Trie.iter(accepted_proposals)) {
            switch (await execute_proposal(proposal)) {
            case (#ok) { update_proposal_state(proposal, #succeeded); };
            case (#err(err)) { update_proposal_state(proposal, #failed(err)); };
            };
        };
    };

    /// Verilen öneriyi yürütür
    func execute_proposal(proposal: Types.Proposal) : async Types.Result<(), Text> {
        try {
            let payload = proposal.payload;
            ignore await ICRaw.call(payload.canister_id, payload.method, payload.message);
            #ok
        }
        catch (e) { #err(Error.message e) };
    };

    func update_proposal_state(proposal: Types.Proposal, state: Types.ProposalState) {
        let updated = {
            state;
            id = proposal.id;
            votes_yes = proposal.votes_yes;
            votes_no = proposal.votes_no;
            voters = proposal.voters;
            timestamp = proposal.timestamp;
            proposer = proposal.proposer;
            payload = proposal.payload;
        };
        proposal_put(proposal.id, updated);
    };
};

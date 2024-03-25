import Result "mo:base/Result";
import Trie "mo:base/Trie";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import List "mo:base/List";
import Principal "mo:base/Principal";

module {
  // Sonuç türünü içe aktarır.
  public type Result<T, E> = Result.Result<T, E>;
  
  // Hesap veri yapısını tanımlar.
  public type Account = { owner : Principal; tokens : Tokens };
  
  // Öneri veri yapısını tanımlar.
  public type Proposal = {
    id : Nat;
    votes_no : Tokens;
    voters : List.List<Principal>;
    state : ProposalState;
    timestamp : Int;
    proposer : Principal;
    votes_yes : Tokens;
    payload : ProposalPayload;
  };
  
  // Öneri içeriği veri yapısını tanımlar.
  public type ProposalPayload = {
    method : Text;
    canister_id : Principal;
    message : Blob;
  };
  
  // Öneri durumu veri yapısını tanımlar.
  public type ProposalState = {
      // Öneri yürütülürken bir hata meydana geldi.
      #failed : Text;
      // Öneri oylamaya açık.
      #open;
      // Öneri şu anda yürütülüyor.
      #executing;
      // Öneriyi reddetmek için yeterli "hayır" oyu verildi ve yürütülmeyecek.
      #rejected;
      // Öneri başarıyla yürütüldü.
      #succeeded;
      // Öneriyi kabul etmek için yeterli "evet" oyu verildi ve yakında yürütülecek.
      #accepted;
  };
  
  // Token veri yapısını tanımlar.
  public type Tokens = { amount_e8s : Nat };
  
  // Transfer argümanlarını tanımlar.
  public type TransferArgs = { to : Principal; amount : Tokens };
  
  // Sistem Parametrelerini Güncelleme içeriğini tanımlar.
  public type UpdateSystemParamsPayload = {
    transfer_fee : ?Tokens;
    proposal_vote_threshold : ?Tokens;
    proposal_submission_deposit : ?Tokens;
  };
  
  // Oy veri yapısını tanımlar.
  public type Vote = { #no; #yes };
  
  // Oy argümanlarını tanımlar.
  public type VoteArgs = { vote : Vote; proposal_id : Nat };

  // Sistem Parametrelerini tanımlar.
  public type SystemParams = {
    transfer_fee: Tokens;

    // Bir öneriyi kabul etmek için gereken token miktarı veya reddetmek için gereken token miktarı.
    proposal_vote_threshold: Tokens;

    // Bir kullanıcının bir öneri göndermesi durumunda geçici olarak hesabından düşülecek token miktarı.
    // Öneri kabul edilirse, bu depozito geri verilir, aksi halde kaybedilir.
    proposal_submission_deposit: Tokens;
  };
  
  // Temel DAO Kararlı Depo veri yapısını tanımlar.
  public type BasicDaoStableStorage = {
    accounts: [Account];
    proposals: [Proposal];
    system_params: SystemParams;
  };

  // Nat türünden bir değer için öneri anahtarını döndürür.
  public func proposal_key(t: Nat) : Trie.Key<Nat> = { key = t; hash = Int.hash t };
  
  // Principal türünden bir değer için hesap anahtarını döndürür.
  public func account_key(t: Principal) : Trie.Key<Principal> = { key = t; hash = Principal.hash t };
  
  // Hesapları bir dizi olarak alır ve Trie yapısına dönüştürür.
  public func accounts_fromArray(arr: [Account]) : Trie.Trie<Principal, Tokens> {
      var s = Trie.empty<Principal, Tokens>();
      for (account in arr.vals()) {
          s := Trie.put(s, account_key(account.owner), Principal.equal, account.tokens).0;
      };
      s
  };
  
  // Önerileri bir dizi olarak alır ve Trie yapısına dönüştürür.
  public func proposals_fromArray(arr: [Proposal]) : Trie.Trie<Nat, Proposal> {
      var s = Trie.empty<Nat, Proposal>();
      for (proposal in arr.vals()) {
          s := Trie.put(s, proposal_key(proposal.id), Nat.equal, proposal).0;
      };
      s
  };
  
  // Bir token miktarı için tanımlı olan sabit bir token.
  public let oneToken = { amount_e8s = 10_000_000 };
  
  // Sıfır token miktarı için tanımlı olan sabit bir token.
  public let zeroToken = { amount_e8s = 0 };  
}

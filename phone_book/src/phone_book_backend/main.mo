//importlar
import Map "mo:base/HashMap";
import Text "mo:base/Text";

//actor-> canister -> smart contract

actor {
//Motoko type language

type Name = Text;
type Phone = Text;

type Entry = {
  desc: Text;
  phone: Phone;
};

//variable değişken (let immutable var mutable)scope cycle farkı?

let phonebook = Map.HashMap<Name, Entry>(0, Text.equal, Text.hash);

//fonksiyonlar da kendi içinde ikiye ayrılır
//query -> sorgulama
//update -> güncelleme public func update fonksiyonu
public func insert(name: Name, entry: Entry) : async(){
  phonebook.put(name, entry);
};

public query func lookup(name: Name) : async ?Entry {
  phonebook.get(name) //return phonebook.get(name);
};



};

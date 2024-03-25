// actor -> canister -> smart contract
//actor -> actor [projectName]

//imports
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";

actor Tutorial{
  
  //let ->immutable 
  //var -> mutable

  //Type language
  let name: Text = "Ceyda";
  let surname: Text = "Tandogan";

  Debug.print(debug_show (name));
  Debug.print(debug_show (surname));



}
# Phonebook

The Phonebook project is a simple Motoko smart contract that acts as a phonebook, allowing users to store and retrieve contact information.

## Motoko Playground Link

You can try out the Phonebook project in the [Motoko Playground](https://m7sm4-2iaaa-aaaab-qabra-cai.raw.ic0.app/?tag=153066997).

## Overview

The phonebook smart contract enables users to perform the following actions:

- **Insert Entry**: Add a new entry to the phonebook with a name and phone number.
- **Lookup Entry**: Search for an entry by name and retrieve the associated phone number.

## Usage

### Prerequisites

- Ensure you have the Motoko compiler installed.
- Familiarize yourself with the Motoko programming language.

### Smart Contract Definition

The phonebook smart contract defines the following types and functions:

- **Types**:
  - `Name`: Represents the name of a contact.
  - `Phone`: Represents the phone number of a contact.
  - `Entry`: Represents an entry in the phonebook, consisting of a description and a phone number.

- **Functions**:
  - `insert`: Inserts a new entry into the phonebook.
  - `lookup`: Searches for an entry in the phonebook by name and returns the associated entry.

### Deploying and Interacting with the Smart Contract

1. Clone the repository:

   ```bash
   git clone <repository_url>
   ```

2. Navigate to the project directory:

   ```bash
   cd phone_book
   ```

3. Compile the Motoko code:

   ```bash
   dfx build
   ```

4. Deploy the smart contract:

   ```bash
   dfx canister install --all
   ```

5. Interact with the smart contract using query and update calls:

   - **Insert Entry**:
     ```bash
     dfx canister call <canister_id> insert '("<name>", { desc = "<description>", phone = "<phone_number>" })'
     ```

   - **Lookup Entry**:
     ```bash
     dfx canister call <canister_id> lookup '("<name>")'
     ```

## Example Usage

Here's an example of how you can use the phonebook smart contract:

```motoko
import Phonebook "phone_book";

actor Main {
  public func main() : async {
    let phonebookActor = Phonebook.Actor();

    // Inserting a new entry
    await phonebookActor.insert("John Doe", { desc = "Work", phone = "1234567890" });

    // Looking up an entry
    let entry = await phonebookActor.lookup("John Doe");
    switch (entry) {
      case (?entry) {
        print("Phone number for John Doe (" # entry.desc # "): " # entry.phone);
      };
      case null {
        print("John Doe not found in the phonebook.");
      };
    }
  }
}
```

## Contributing

Contributions are welcome! Feel free to open issues or pull requests to suggest improvements or report bugs.

## License

This project is licensed under the [MIT License](LICENSE).
```

Feel free to customize any parts of this README to better suit your project's specific details or requirements.

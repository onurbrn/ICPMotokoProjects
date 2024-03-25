# Motoko Token

This project implements a simple token transfer functionality in the Motoko programming language. It allows users to transfer tokens between accounts using the ICRC1 Ledger Canister.

Use this link to access the code: [Token Code](https://m7sm4-2iaaa-aaaab-qabra-cai.raw.ic0.app/?tag=2615151838)

## Overview

The project defines an actor that facilitates token transfers between accounts. It utilizes the `icrc1_ledger_canister` canister for token transfers.

## Usage

### Prerequisites

- Ensure you have the Motoko compiler installed.
- Familiarize yourself with the Internet Computer and the ICRC1 Ledger Canister.

### Setup

1. Clone the repository:

   ```bash
   git clone <repository_url>
   ```

2. Navigate to the project directory:

   ```bash
   cd motoko_token
   ```

### Running the Application

1. Compile the Motoko code:

   ```bash
   dfx build
   ```

2. Deploy and start the application:

   ```bash
   dfx canister install --all
   dfx canister start <actor_name>
   ```

### Interacting with the Application

You can interact with the application by calling the `transfer` function with appropriate arguments.

- **Transfer Tokens**: Use the `transfer` function to transfer tokens between accounts. Pass the amount to be transferred and the recipient account as arguments.

## Example Usage

```motoko
import MotokoToken "motoko_token";

actor Main {
  public func main() : async {
    let tokenActor = MotokoToken.Actor();

    let toAccount = { owner = principal "abcdef1234567890"; subaccount = null };
    let transferArgs = { amount = 100; toAccount = toAccount };

    let result = await tokenActor.transfer(transferArgs);
    switch (result) {
      case (Result.Ok(blockIndex)) {
        print("Tokens transferred successfully. Block index: " # Nat.toText(blockIndex));
      };
      case (Result.Err(errorMessage)) {
        print("Transfer failed: " # errorMessage);
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

Feel free to modify any parts of this README to better suit your project's specific details or requirements.

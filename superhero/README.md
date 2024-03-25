# Superhero Database

The Superhero Database project is a Motoko smart contract that allows users to manage a database of superheroes, including their names and superpowers.

Use this link to access the code: [Superheroes Code](https://m7sm4-2iaaa-aaaab-qabra-cai.raw.ic0.app/?tag=2940681252)

## Overview

The superhero database smart contract provides the following functionality:

- **Create Superhero**: Add a new superhero to the database.
- **Read Superhero**: Retrieve information about a superhero by their ID.
- **Update Superhero**: Update the information of an existing superhero.
- **Delete Superhero**: Remove a superhero from the database.

## Usage

### Prerequisites

- Ensure you have the Motoko compiler installed.
- Familiarize yourself with the Motoko programming language.

### Smart Contract Definition

The superhero database smart contract defines the following types and functions:

- **Types**:
  - `SuperheroId`: Represents the unique identifier of a superhero.
  - `Superhero`: Represents a superhero, including their name and list of superpowers.

- **Functions**:
  - `create`: Creates a new superhero in the database.
  - `read`: Retrieves information about a superhero by their ID.
  - `update`: Updates the information of an existing superhero.
  - `delete`: Deletes a superhero from the database.

### Deploying and Interacting with the Smart Contract

1. Clone the repository:

   ```bash
   git clone <repository_url>
   ```

2. Navigate to the project directory:

   ```bash
   cd superhero
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

   - **Create Superhero**:
     ```bash
     dfx canister call <canister_id> create '(<superhero>)'
     ```

   - **Read Superhero**:
     ```bash
     dfx canister call <canister_id> read '(<superhero_id>)'
     ```

   - **Update Superhero**:
     ```bash
     dfx canister call <canister_id> update '(<superhero_id>, <updated_superhero>)'
     ```

   - **Delete Superhero**:
     ```bash
     dfx canister call <canister_id> delete '(<superhero_id>)'
     ```

## Example Usage

Here's an example of how you can use the superhero database smart contract:

```motoko
import Superheroes "superhero";

actor Main {
  public func main() : async {
    let superheroActor = Superheroes.Superheroes();

    // Create a new superhero
    let superheroId = await superheroActor.create({
      name = "Superman";
      superpowers = [ "Flight", "Super strength", "Heat vision" ];
    });

    // Read information about the superhero
    let superhero = await superheroActor.read(superheroId);
    switch (superhero) {
      case (?hero) {
        print("Superhero name: " # hero.name);
        print("Superpowers: " # List.toString(hero.superpowers));
      };
      case null {
        print("Superhero not found.");
      };
    }

    // Update superhero information
    let updatedSuperhero = {
      name = "Superman";
      superpowers = [ "Flight", "Super strength", "Heat vision", "X-ray vision" ];
    };
    let updateResult = await superheroActor.update(superheroId, updatedSuperhero);
    if (updateResult) {
      print("Superhero information updated successfully.");
    } else {
      print("Failed to update superhero information.");
    }

    // Delete the superhero from the database
    let deleteResult = await superheroActor.delete(superheroId);
    if (deleteResult) {
      print("Superhero deleted successfully.");
    } else {
      print("Failed to delete superhero.");
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

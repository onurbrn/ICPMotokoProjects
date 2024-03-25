
# Basic Todo

This project implements a simple todo list application in the Motoko programming language. Users can add tasks, mark them as completed, view all tasks, and clear completed tasks.

Use this link to access the code: [Todo Code](https://m7sm4-2iaaa-aaaab-qabra-cai.raw.ic0.app/?tag=2404385365)

## Usage

### Prerequisites

- Ensure you have the Motoko compiler installed.
- Familiarize yourself with the Motoko programming language.

### Setup

1. Clone the repository:

   ```bash
   git clone <repository_url>
   ```

2. Navigate to the project directory:

   ```bash
   cd basic_todo
   ```

### Running the Application

1. Compile the Motoko code:

   ```bash
   dfx build
   ```

2. Deploy and start the application:

   ```bash
   dfx canister install --all
   dfx canister start assistant
   ```

### Interacting with the Application

You can interact with the application using the following methods:

- **Add a Todo**: Use the `addTodo` function to add a new todo item. Provide the description of the task as an argument.
- **Complete a Todo**: Mark a todo item as completed using the `completeTodo` function. Pass the ID of the todo item to mark it as completed.
- **Show Todos**: View all todos using the `showTodos` function. It returns a list of all todos along with their completion status.
- **Clear Completed Todos**: Use the `clearCompleted` function to remove all completed todos from the list.

## Example Usage

```motoko
import BasicTodo "basic_todo";

actor Main {
  public func main() : async {
    let todoApp = BasicTodo.Assistant();

    let todo1 = await todoApp.addTodo("Complete project report");
    let todo2 = await todoApp.addTodo("Buy groceries");

    await todoApp.completeTodo(todo1);

    let todos = await todoApp.getTodos();
    for (todo in todos) {
      print(todo.description);
      if (todo.completed) {
        print(" - Completed");
      } else {
        print(" - Pending");
      }
    }

    await todoApp.clearCompleted();
  }
}
```

## Contributing

Contributions are welcome! Feel free to open issues or pull requests to suggest improvements or report bugs.

## License

This project is licensed under the [MIT License](LICENSE).
```

Feel free to adjust any parts of this README to better suit your project's specific details or requirements.

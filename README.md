#### Preview


<p align="leading">
  <img src="https://github.com/Saydulayev/ToDoList-VIPER/blob/main/ToDO%20LIst/Screenshot/Simulator%20Screenshot.png" width="300">
</p>


# ToDo List App (VIPER)

🎉 **ToDo List App** is a task management application built using the **VIPER** architecture, **Core Data** for data persistence, and **GCD** for multithreading. This project was part of a technical assignment with a 7-day deadline, completed in just 3 days.

## 📋 Project Requirements

The app allows users to:

- Display a list of tasks.
- Add new tasks.
- Edit existing tasks.
- Delete tasks.
- Each task includes a title, description, creation date, and completion status (completed/not completed).

Additionally:

- Task list is loaded from an **API** (https://dummyjson.com/todos) on the first launch.
- Data is saved locally using **Core Data**.
- Task creation, editing, loading, and deletion are performed in the background using **GCD**, ensuring smooth UI performance.

## 💡 Technologies

- **VIPER** — for clear separation of responsibilities between components: View, Interactor, Presenter, Entity, and Router.
- **Core Data** — for persistent data storage and management.
- **GCD (Grand Central Dispatch)** — to handle background tasks without blocking the UI.
- **SwiftUI** — for building the user interface.

## 📦 Installation

### Requirements:
- **Xcode 12** or later.
- **iOS 14** or later.

### Steps to run the project:

1. Clone the repository:
    ```bash
    git clone https://github.com/your-username/todo-list-app.git
    ```

2. Open the project in Xcode:
    ```bash
    open ToDoListApp.xcodeproj
    ```

3. Run the project on a simulator or device by pressing the **Run** button in Xcode.

## 🧪 Unit Tests

The app includes unit tests for core components. To run the tests:

1. Select **Product > Test** in Xcode.
2. Ensure that all tests pass successfully.

## 🛠️ Project Structure

The project follows the **VIPER** architecture, ensuring a clear separation of concerns and easier code maintenance.

- **View**: Displays data and passes user actions to the Presenter.
- **Interactor**: Contains business logic and processes data.
- **Presenter**: Connects the View and Interactor, managing the presentation logic.
- **Entity**: Data model used in the app.
- **Router**: Handles navigation between screens.

## 📝 License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for more details.

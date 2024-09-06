### README.md

# ToDo List App

## Overview
ToDo List App is a task management application built with Swift and SwiftUI, leveraging the VIPER architecture to ensure a clean separation of concerns, high testability, and scalability. The app enables users to create, edit, and manage tasks efficiently while maintaining a responsive and modern UI.

## Features
- **Task Management**: Add, edit, delete tasks.
- **Filtering and Sorting**: Filter tasks by status and sort them by title or creation date.
- **Task Completion**: Toggle task completion status.
- **Persistence**: Core Data integration for local storage.
- **Networking**: Fetch tasks from a remote API.
- **SwiftUI Interface**: Clean, responsive design with SwiftUI.

## Architecture
The application follows the VIPER pattern:

- **View**: SwiftUI views like `ContentView`, `TaskListView`, and `NewTaskView`. These are responsible for displaying data and interacting with the Presenter.
- **Interactor**: Handles business logic and data management (`TaskInteractor`). It communicates with Core Data and fetches data from APIs.
- **Presenter**: Acts as the mediator between the View and Interactor (`TaskPresenter`). It formats data for the View and processes user actions.
- **Entity**: Core Data entities like `TaskEntity` define the data model.
- **Router**: While not explicitly used in this project, routing would typically manage navigation logic.

## Core Data
Core Data is used for persistence, providing offline access to tasks. The `TaskInteractor` handles CRUD operations with Core Data, ensuring data consistency and performance.

## Networking
The app includes functionality to fetch tasks from a remote API, demonstrating how the architecture can handle asynchronous data loading and syncing with local storage.

## Testing
The app is covered by unit tests, primarily focusing on the `TaskPresenter`. The tests ensure the integrity of the business logic and include:

- **Presenter Tests**: Verify task loading, sorting, filtering, and state changes.
- **Mock Interactor**: Used to isolate the Presenter logic and simulate data operations without reliance on actual data sources.

### Principles
- **Modularity**: Each component has a single responsibility, making the codebase easier to understand and extend.
- **Testability**: VIPER’s clear separation of concerns allows for isolated unit testing, particularly of the business logic.
- **Scalability**: The architecture is designed to accommodate additional features and complexity without significant refactoring.

### Installation
Clone the repository and open the project in Xcode:

```bash
git clone https://github.com/your-username/todo-list-app.git
cd todo-list-app
open ToDoList.xcodeproj
```

### Running the App
Select a target device and run the app using `Cmd + R`.

### Running Tests
To run the unit tests, use `Cmd + U` in Xcode.


## License
This project is licensed under the MIT License.

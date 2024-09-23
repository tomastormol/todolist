//
//  TaskManager.swift
//  ToDoList
//
//  Created by Tomas on 19/9/24.
//

import Foundation

struct TodoTask: Identifiable, Codable {
    var id = UUID()
    let title: String
    let date: Date
}

class TaskManager: ObservableObject {
    @Published var tasks: [TodoTask] = []
    
    private let tasksKey = "tasks_key" // Clave para guardar las tareas
    
    init() {
        loadTasks()
    }

    // Añadir una nueva tarea y guardarla
    func addTask(title: String, date: Date) {
        let task = TodoTask(title: title, date: date)
        tasks.append(task)
        saveTasks()
    }

    // Eliminar una tarea y guardar
    func removeTask(_ task: TodoTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
            saveTasks()
        }
    }

    // Guardar las tareas en UserDefaults
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }

    // Cargar las tareas desde UserDefaults
    private func loadTasks() {
        if let savedData = UserDefaults.standard.data(forKey: tasksKey),
           let decodedTasks = try? JSONDecoder().decode([TodoTask].self, from: savedData) {
            self.tasks = decodedTasks
        }
    }
}

import SwiftUI
import UserNotifications

struct TodoView: View {
    @StateObject private var taskManager = TaskManager() // Utiliza el TaskManager como fuente de datos
    @State private var newTask: String = ""
    @State private var taskDate: Date = Date()
    @State private var isAddingTask: Bool = false // Controla la visibilidad del TextField

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(taskManager.tasks) { task in
                        TodoItem(todoTask: task, removeTodoTask: { taskToRemove in
                            taskManager.removeTask(taskToRemove)
                        })
                        .listRowBackground(Color.clear)
                    }
                    
                    if isAddingTask {
                        AddTaskView(newTask: $newTask, taskDate: $taskDate, taskManager: taskManager, scheduleNotification: scheduleNotification, isAddingTask: $isAddingTask)
                    }
                }
                .listStyle(.plain)
                .padding(.top, 16)
                .padding(.leading, 8)

                Spacer()

                AddTodoTaskButton(isAddingTask: $isAddingTask)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.backgroundApp)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Todo")
                        .font(.title)
                        .bold()
                        .foregroundColor(.colorRed)
                        .padding(8)
                }
            }
            .onAppear {
                requestNotificationPermission() // Solicitar permisos para las notificaciones
            }
        }
    }
    
    // Solicitar permisos para notificaciones
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error al solicitar permiso para notificaciones: \(error.localizedDescription)")
            }
        }
    }

    // Programar una notificación para una tarea
    func scheduleNotification(for task: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio"
        content.body = "No olvides: \(task)"
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error al programar la notificación: \(error.localizedDescription)")
            }
        }
    }
}

struct TodoItem: View {
    let todoTask: TodoTask
    let removeTodoTask: (TodoTask) -> Void
    
    // Formatear la fecha y la hora en una sola línea
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy 'at' HH:mm" // Ajusta el formato según tus preferencias
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack {
            Button(action: {
                removeTodoTask(todoTask) // Elimina la tarea
            }) {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading) {
                Text(todoTask.title)
                    .font(.title3)
                    .foregroundColor(.white)
                Text(formattedDate(todoTask.date)) // Mostrar la fecha seleccionada
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct AddTaskView: View {
    @Binding var newTask: String
    @Binding var taskDate: Date
    var taskManager: TaskManager
    var scheduleNotification: (String, Date) -> Void
    @Binding var isAddingTask: Bool

    var body: some View {
        VStack {
            HStack {
                TextField("", text: $newTask, prompt: Text("Write new Todo")
                    .foregroundColor(.gray) // Texto de placeholder más suave
                )
                .foregroundColor(.white) // Color del texto introducido
                .padding()
                .background(Color.black.opacity(0.8)) // Fondo del TextField más oscuro
                .cornerRadius(10) // Bordes redondeados para un look más moderno

                Button(action: {
                    taskManager.addTask(title: newTask, date: taskDate) // Usar addTask del TaskManager
                    scheduleNotification(newTask, taskDate) // Programar notificación
                    newTask = "" // Limpiar el campo de texto
                    isAddingTask = false // Ocultar el formulario
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.black.opacity(0.8))
                        .font(.title)
                }
                .padding(.leading, 8)
            }
            .padding(.vertical, 8)

            // Personalizar la apariencia del DatePicker
            DatePicker("Date & Time", selection: $taskDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(CompactDatePickerStyle())
                .cornerRadius(10)
                .accentColor(.gray) // Color del selector
                .foregroundColor(.gray) // Color del texto de la etiqueta
        }
    }
}

struct AddTodoTaskButton: View {
    @Binding var isAddingTask: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                isAddingTask.toggle() // Mostrar u ocultar el formulario
            }) {
                Image(systemName: "plus.circle.fill")
                Text("New Reminder")
            }
            .padding(8)
            .foregroundColor(.colorRed)
            .bold()
            .font(.title3)

            Spacer() // Empuja el botón hacia la izquierda
        }
        .padding(.leading)
        .padding(.bottom, 16) // Espacio con el borde inferior
    }
}


#Preview {
    TodoView()
//    TodoItem(todoTask: TodoTask(title: "Ejemplo de tarea", date: Date()), removeTodoTask: { _ in })
}

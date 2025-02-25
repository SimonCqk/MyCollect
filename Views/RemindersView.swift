import SwiftUI
import PhotosUI

struct RemindersView: View {
    @EnvironmentObject private var assetManager: AssetManager
    @State private var showingAddReminder = false
    @State private var selectedItem: AssetItem?
    
    private var reminders: [AssetReminder] {
        assetManager.items.flatMap { $0.reminders }
            .sorted { $0.date < $1.date }
    }
    
    private var upcomingReminders: [AssetReminder] {
        reminders.filter { !$0.isCompleted }
    }
    
    private var completedReminders: [AssetReminder] {
        reminders.filter { $0.isCompleted }
    }
    
    var body: some View {
        List {
            if upcomingReminders.isEmpty && completedReminders.isEmpty {
                Text("暂无提醒事项")
                    .foregroundColor(.secondary)
            } else {
                // 即将到期的提醒
                if !upcomingReminders.isEmpty {
                    Section("待办提醒") {
                        ForEach(upcomingReminders) { reminder in
                            ReminderRow(reminder: reminder)
                        }
                    }
                }
                
                // 已完成的提醒
                if !completedReminders.isEmpty {
                    Section("已完成") {
                        ForEach(completedReminders) { reminder in
                            ReminderRow(reminder: reminder)
                        }
                    }
                }
            }
        }
        .navigationTitle("提醒事项")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ForEach(assetManager.items) { item in
                        Button(item.name) {
                            selectedItem = item
                            showingAddReminder = true
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddReminder) {
            if let item = selectedItem {
                AddReminderView(itemId: item.id)
            }
        }
    }
}

struct ReminderRow: View {
    let reminder: AssetReminder
    @EnvironmentObject private var assetManager: AssetManager
    
    private var item: AssetItem? {
        assetManager.items.first { $0.reminders.contains { $0.id == reminder.id } }
    }
    
    var body: some View {
        HStack {
            // 复选框
            Button {
                toggleReminder()
            } label: {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(reminder.isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .strikethrough(reminder.isCompleted)
                
                HStack {
                    if let item = item {
                        Text(item.name)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("·")
                        .foregroundColor(.secondary)
                    
                    Text(reminder.date.formatted(date: .numeric, time: .shortened))
                        .foregroundColor(.secondary)
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func toggleReminder() {
        guard var item = item else { return }
        if let index = item.reminders.firstIndex(where: { $0.id == reminder.id }) {
            item.reminders[index].isCompleted.toggle()
            assetManager.updateItem(item)
        }
    }
}

#Preview {
    NavigationView {
        RemindersView()
            .environmentObject(AssetManager())
    }
}

struct AddReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var assetManager: AssetManager
    let itemId: UUID
    
    @State private var title = ""
    @State private var date = Date()
    @State private var note = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("标题", text: $title)
                    DatePicker("日期", selection: $date, displayedComponents: [.date])
                    TextField("备注", text: $note)
                }
            }
            .navigationTitle("添加提醒")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        addReminder()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addReminder() {
        guard var item = assetManager.getItem(withId: itemId) else { return }
        let reminder = AssetReminder(
            title: title,
            date: date,
            isCompleted: false
        )
        item.reminders.append(reminder)
        assetManager.updateItem(item)
    }
}

#Preview {
    AddReminderView(itemId: UUID())
        .environmentObject(AssetManager())
}


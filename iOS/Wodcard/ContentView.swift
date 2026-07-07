import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: LogEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.entries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            EntryRow(entry: entry)
                                .listRowBackground(Theme.cardBackground)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingEntry = entry
                                }
                        }
                        .onDelete(perform: store.delete)
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Wodcard")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMoreFree || purchases.isPro {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryEditorView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryEditorView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 44))
                .foregroundStyle(Theme.accent)
            Text("No \(LogEntry.entryNoun.lowercased())s yet")
                .font(Theme.titleFont)
                .foregroundStyle(Theme.textPrimary)
            Text("Tap + to log your first \(LogEntry.entryNoun.lowercased()).")
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding()
    }
}

struct EntryRow: View {
    let entry: LogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.title)
                    .font(Theme.bodyFont.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text(entry.date, style: .date)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
            }
            HStack(spacing: 16) {
                Label("\(entry.value1.formatted()) \(LogEntry.value1Unit)", systemImage: "chart.bar.fill")
                Label("\(entry.value2.formatted()) \(LogEntry.value2Unit)", systemImage: "clock.fill")
            }
            .font(Theme.captionFont)
            .foregroundStyle(Theme.accent)
            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EntryEditorView: View {
    @Environment(\.dismiss) var dismiss
    let entry: LogEntry?
    let onSave: (LogEntry) -> Void

    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var value1Text: String = ""
    @State private var value2Text: String = ""
    @State private var notes: String = ""
    @FocusState private var focusedField: Field?

    enum Field { case title, value1, value2, notes }

    var body: some View {
        NavigationStack {
            Form {
                Section("WOD details") {
                    TextField("Title", text: $title)
                        .focused($focusedField, equals: .title)
                        .accessibilityIdentifier("titleField")
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                Section("Numbers") {
                    TextField("Time (sec)", text: $value1Text)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .value1)
                        .accessibilityIdentifier("value1Field")
                    TextField("Rounds/reps (reps)", text: $value2Text)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .value2)
                        .accessibilityIdentifier("value2Field")
                }
                Section("Workout notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .focused($focusedField, equals: .notes)
                        .accessibilityIdentifier("notesField")
                }
            }
            .navigationTitle(entry == nil ? "New WOD" : "Edit WOD")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let result = LogEntry(
                            id: entry?.id ?? UUID(),
                            title: title.isEmpty ? "Untitled" : title,
                            date: date,
                            value1: Double(value1Text) ?? 0,
                            value2: Double(value2Text) ?? 0,
                            notes: notes
                        )
                        onSave(result)
                        dismiss()
                    }
                    .accessibilityIdentifier("saveEntryButton")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .onAppear {
                if let entry {
                    title = entry.title
                    date = entry.date
                    value1Text = String(entry.value1)
                    value2Text = String(entry.value2)
                    notes = entry.notes
                }
            }
        }
    }
}

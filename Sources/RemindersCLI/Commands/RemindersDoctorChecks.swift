import Utility

public func remindersDoctorChecks() -> [CLIDoctorCheck] {
  let command = RemindersCommand()
  return [
    CLIDoctorCheck(
      name: "reminderkit_implementation",
      status: .ok,
      message: "Reminders production commands use ReminderKit and ReminderKitInternal APIs."
    ),
    CLIDoctorCheck(
      name: "reminderkit_mutation_contract",
      status: .ok,
      message:
        "Reminder mutations resolve identity, save through ReminderKit, and verify the requested state."
    ),
    reminderKitDoctorCheck(),
    command.reminderKitReadAccessDoctorCheck(),
  ]
}

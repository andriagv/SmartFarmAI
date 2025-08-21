import SwiftUI

struct CalendarView: View {
    let dates: [Date]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(dates, id: \.self) { date in
                HStack {
                    Image(systemName: "calendar")
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                    Spacer()
                }
                .padding(8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}



import 'package:board_event_bus/board_event_bus.dart';

enum EventName {
  eventA,
  eventB,
}

void main() {
  final bus = EventBus<EventName>();
  bus.subscribe(EventName.eventA, (arg) {
    print('eventA subscribe1: $arg');
  });
  bus.subscribe(EventName.eventA, (arg) {
    print('eventA subscribe2: $arg');
  });
  bus.subscribe(EventName.eventB, (arg) {
    print('eventB subscribe1: $arg');
  });
  bus.subscribe(EventName.eventB, (arg) {
    print('eventB subscribe2: $arg');
  });
  bus.publish(EventName.eventA);
  bus.publish(EventName.eventB, 'HelloWorld');
}

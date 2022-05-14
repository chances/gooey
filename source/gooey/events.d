/// Event handling and event loop primitives.
///
/// Authors: Chance Snow
/// Copyright: Copyright © 2022 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.events;

import eventcore.core : EventDriverCore, eventDriver, tryGetEventDriver;

/// Lazily create or retrieve an event loop for this thread.
package(gooey) auto eventLoop() {
  return eventDriver().events;
}

/// Releases this thread's event loop when it is destroyed.
/// See https://dlang.org/spec/module.html#staticorder
static ~this() {
  import core.time : Duration;

  if (auto eventLoop = tryGetEventDriver()) {
    eventLoop.core.exit();
    eventLoop.core.processEvents(Duration.zero);
    eventLoop.destroy();
  }
}

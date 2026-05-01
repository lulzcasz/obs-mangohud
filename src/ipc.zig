const std = @import("std");

pub export fn message_from_ipc() [*:0]const u8 {
    return "Hello World";
}

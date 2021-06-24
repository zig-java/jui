# jui

jui or the Java Universal Interface is a set of Zig-intuitive bindings for JNI, the Java Native Interface.

## Taking jui for a spin

```bash
# Build the demo
zig build

# Run the demo
java -Djava.library.path="zig-out/lib" test/src/com/jui/JNIExample.java
```

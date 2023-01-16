const std = @import("std");
const jui = @import("jui");
/// Opaque type corresponding to java/util/Scanner
pub const Scanner = opaque {
    const classpath = "java/util/Scanner";
    var class_global: jui.jclass = null;
    var fields: struct {
        @"buf_Ljava/nio/CharBuffer;": jui.jfieldID,
        @"BUFFER_SIZE_I": jui.jfieldID,
        @"position_I": jui.jfieldID,
        @"matcher_Ljava/util/regex/Matcher;": jui.jfieldID,
        @"delimPattern_Ljava/util/regex/Pattern;": jui.jfieldID,
        @"hasNextPattern_Ljava/util/regex/Pattern;": jui.jfieldID,
        @"hasNextPosition_I": jui.jfieldID,
        @"hasNextResult_Ljava/lang/String;": jui.jfieldID,
        @"source_Ljava/lang/Readable;": jui.jfieldID,
        @"sourceClosed_Z": jui.jfieldID,
        @"needInput_Z": jui.jfieldID,
        @"skipped_Z": jui.jfieldID,
        @"savedScannerPosition_I": jui.jfieldID,
        @"typeCache_Ljava/lang/Object;": jui.jfieldID,
        @"matchValid_Z": jui.jfieldID,
        @"closed_Z": jui.jfieldID,
        @"radix_I": jui.jfieldID,
        @"defaultRadix_I": jui.jfieldID,
        @"locale_Ljava/util/Locale;": jui.jfieldID,
        @"patternCache_Ljava/util/Scanner$PatternLRUCache;": jui.jfieldID,
        @"lastException_Ljava/io/IOException;": jui.jfieldID,
        @"modCount_I": jui.jfieldID,
        @"WHITESPACE_PATTERN_Ljava/util/regex/Pattern;": jui.jfieldID,
        @"FIND_ANY_PATTERN_Ljava/util/regex/Pattern;": jui.jfieldID,
        @"NON_ASCII_DIGIT_Ljava/util/regex/Pattern;": jui.jfieldID,
        @"groupSeparator_Ljava/lang/String;": jui.jfieldID,
        @"decimalSeparator_Ljava/lang/String;": jui.jfieldID,
        @"nanString_Ljava/lang/String;": jui.jfieldID,
        @"infinityString_Ljava/lang/String;": jui.jfieldID,
        @"positivePrefix_Ljava/lang/String;": jui.jfieldID,
        @"negativePrefix_Ljava/lang/String;": jui.jfieldID,
        @"positiveSuffix_Ljava/lang/String;": jui.jfieldID,
        @"negativeSuffix_Ljava/lang/String;": jui.jfieldID,
        @"boolPattern_Ljava/util/regex/Pattern;": jui.jfieldID,
        @"BOOLEAN_PATTERN_Ljava/lang/String;": jui.jfieldID,
        @"integerPattern_Ljava/util/regex/Pattern;": jui.jfieldID,
        @"digits_Ljava/lang/String;": jui.jfieldID,
        @"non0Digit_Ljava/lang/String;": jui.jfieldID,
        @"SIMPLE_GROUP_INDEX_I": jui.jfieldID,
        @"separatorPattern_Ljava/util/regex/Pattern;": jui.jfieldID,
        @"linePattern_Ljava/util/regex/Pattern;": jui.jfieldID,
        @"LINE_SEPARATOR_PATTERN_Ljava/lang/String;": jui.jfieldID,
        @"LINE_PATTERN_Ljava/lang/String;": jui.jfieldID,
        @"floatPattern_Ljava/util/regex/Pattern;": jui.jfieldID,
        @"decimalPattern_Ljava/util/regex/Pattern;": jui.jfieldID,
        @"$assertionsDisabled_Z": jui.jfieldID,
    } = undefined;
    var methods: struct {
        @"boolPattern()Ljava/util/regex/Pattern;": jui.jmethodID,
        @"buildIntegerPatternString()Ljava/lang/String;": jui.jmethodID,
        @"integerPattern()Ljava/util/regex/Pattern;": jui.jmethodID,
        @"separatorPattern()Ljava/util/regex/Pattern;": jui.jmethodID,
        @"linePattern()Ljava/util/regex/Pattern;": jui.jmethodID,
        @"buildFloatAndDecimalPattern()V": jui.jmethodID,
        @"floatPattern()Ljava/util/regex/Pattern;": jui.jmethodID,
        @"decimalPattern()Ljava/util/regex/Pattern;": jui.jmethodID,
        @"<init>(Ljava/lang/Readable;Ljava/util/regex/Pattern;)V": jui.jmethodID,
        @"<init>(Ljava/lang/Readable;)V": jui.jmethodID,
        @"<init>(Ljava/io/InputStream;)V": jui.jmethodID,
        @"<init>(Ljava/io/InputStream;Ljava/lang/String;)V": jui.jmethodID,
        @"<init>(Ljava/io/InputStream;Ljava/nio/charset/Charset;)V": jui.jmethodID,
        @"toCharset(Ljava/lang/String;)Ljava/nio/charset/Charset;": jui.jmethodID,
        @"makeReadable(Ljava/nio/file/Path;Ljava/nio/charset/Charset;)Ljava/lang/Readable;": jui.jmethodID,
        @"makeReadable(Ljava/io/InputStream;Ljava/nio/charset/Charset;)Ljava/lang/Readable;": jui.jmethodID,
        @"<init>(Ljava/io/File;)V": jui.jmethodID,
        @"<init>(Ljava/io/File;Ljava/lang/String;)V": jui.jmethodID,
        @"<init>(Ljava/io/File;Ljava/nio/charset/Charset;)V": jui.jmethodID,
        @"<init>(Ljava/io/File;Ljava/nio/charset/CharsetDecoder;)V": jui.jmethodID,
        @"toDecoder(Ljava/lang/String;)Ljava/nio/charset/CharsetDecoder;": jui.jmethodID,
        @"makeReadable(Ljava/nio/channels/ReadableByteChannel;Ljava/nio/charset/CharsetDecoder;)Ljava/lang/Readable;": jui.jmethodID,
        @"makeReadable(Ljava/nio/channels/ReadableByteChannel;Ljava/nio/charset/Charset;)Ljava/lang/Readable;": jui.jmethodID,
        @"<init>(Ljava/nio/file/Path;)V": jui.jmethodID,
        @"<init>(Ljava/nio/file/Path;Ljava/lang/String;)V": jui.jmethodID,
        @"<init>(Ljava/nio/file/Path;Ljava/nio/charset/Charset;)V": jui.jmethodID,
        @"<init>(Ljava/lang/String;)V": jui.jmethodID,
        @"<init>(Ljava/nio/channels/ReadableByteChannel;)V": jui.jmethodID,
        @"makeReadable(Ljava/nio/channels/ReadableByteChannel;)Ljava/lang/Readable;": jui.jmethodID,
        @"<init>(Ljava/nio/channels/ReadableByteChannel;Ljava/lang/String;)V": jui.jmethodID,
        @"<init>(Ljava/nio/channels/ReadableByteChannel;Ljava/nio/charset/Charset;)V": jui.jmethodID,
        @"saveState()V": jui.jmethodID,
        @"revertState()V": jui.jmethodID,
        @"revertState(Z)Z": jui.jmethodID,
        @"cacheResult()V": jui.jmethodID,
        @"cacheResult(Ljava/lang/String;)V": jui.jmethodID,
        @"clearCaches()V": jui.jmethodID,
        @"getCachedResult()Ljava/lang/String;": jui.jmethodID,
        @"useTypeCache()V": jui.jmethodID,
        @"readInput()V": jui.jmethodID,
        @"makeSpace()Z": jui.jmethodID,
        @"translateSavedIndexes(I)V": jui.jmethodID,
        @"throwFor()V": jui.jmethodID,
        @"hasTokenInBuffer()Z": jui.jmethodID,
        @"getCompleteTokenInBuffer(Ljava/util/regex/Pattern;)Ljava/lang/String;": jui.jmethodID,
        @"findPatternInBuffer(Ljava/util/regex/Pattern;I)Z": jui.jmethodID,
        @"matchPatternInBuffer(Ljava/util/regex/Pattern;)Z": jui.jmethodID,
        @"ensureOpen()V": jui.jmethodID,
        @"close()V": jui.jmethodID,
        @"ioException()Ljava/io/IOException;": jui.jmethodID,
        @"delimiter()Ljava/util/regex/Pattern;": jui.jmethodID,
        @"useDelimiter(Ljava/util/regex/Pattern;)Ljava/util/Scanner;": jui.jmethodID,
        @"useDelimiter(Ljava/lang/String;)Ljava/util/Scanner;": jui.jmethodID,
        @"locale()Ljava/util/Locale;": jui.jmethodID,
        @"useLocale(Ljava/util/Locale;)Ljava/util/Scanner;": jui.jmethodID,
        @"radix()I": jui.jmethodID,
        @"useRadix(I)Ljava/util/Scanner;": jui.jmethodID,
        @"setRadix(I)V": jui.jmethodID,
        @"match()Ljava/util/regex/MatchResult;": jui.jmethodID,
        @"toString()Ljava/lang/String;": jui.jmethodID,
        @"hasNext()Z": jui.jmethodID,
        @"next()Ljava/lang/String;": jui.jmethodID,
        @"remove()V": jui.jmethodID,
        @"hasNext(Ljava/lang/String;)Z": jui.jmethodID,
        @"next(Ljava/lang/String;)Ljava/lang/String;": jui.jmethodID,
        @"hasNext(Ljava/util/regex/Pattern;)Z": jui.jmethodID,
        @"next(Ljava/util/regex/Pattern;)Ljava/lang/String;": jui.jmethodID,
        @"hasNextLine()Z": jui.jmethodID,
        @"nextLine()Ljava/lang/String;": jui.jmethodID,
        @"findInLine(Ljava/lang/String;)Ljava/lang/String;": jui.jmethodID,
        @"findInLine(Ljava/util/regex/Pattern;)Ljava/lang/String;": jui.jmethodID,
        @"findWithinHorizon(Ljava/lang/String;I)Ljava/lang/String;": jui.jmethodID,
        @"findWithinHorizon(Ljava/util/regex/Pattern;I)Ljava/lang/String;": jui.jmethodID,
        @"skip(Ljava/util/regex/Pattern;)Ljava/util/Scanner;": jui.jmethodID,
        @"skip(Ljava/lang/String;)Ljava/util/Scanner;": jui.jmethodID,
        @"hasNextBoolean()Z": jui.jmethodID,
        @"nextBoolean()Z": jui.jmethodID,
        @"hasNextByte()Z": jui.jmethodID,
        @"hasNextByte(I)Z": jui.jmethodID,
        @"nextByte()B": jui.jmethodID,
        @"nextByte(I)B": jui.jmethodID,
        @"hasNextShort()Z": jui.jmethodID,
        @"hasNextShort(I)Z": jui.jmethodID,
        @"nextShort()S": jui.jmethodID,
        @"nextShort(I)S": jui.jmethodID,
        @"hasNextInt()Z": jui.jmethodID,
        @"hasNextInt(I)Z": jui.jmethodID,
        @"processIntegerToken(Ljava/lang/String;)Ljava/lang/String;": jui.jmethodID,
        @"nextInt()I": jui.jmethodID,
        @"nextInt(I)I": jui.jmethodID,
        @"hasNextLong()Z": jui.jmethodID,
        @"hasNextLong(I)Z": jui.jmethodID,
        @"nextLong()J": jui.jmethodID,
        @"nextLong(I)J": jui.jmethodID,
        @"processFloatToken(Ljava/lang/String;)Ljava/lang/String;": jui.jmethodID,
        @"hasNextFloat()Z": jui.jmethodID,
        @"nextFloat()F": jui.jmethodID,
        @"hasNextDouble()Z": jui.jmethodID,
        @"nextDouble()D": jui.jmethodID,
        @"hasNextBigInteger()Z": jui.jmethodID,
        @"hasNextBigInteger(I)Z": jui.jmethodID,
        @"nextBigInteger()Ljava/math/BigInteger;": jui.jmethodID,
        @"nextBigInteger(I)Ljava/math/BigInteger;": jui.jmethodID,
        @"hasNextBigDecimal()Z": jui.jmethodID,
        @"nextBigDecimal()Ljava/math/BigDecimal;": jui.jmethodID,
        @"reset()Ljava/util/Scanner;": jui.jmethodID,
        @"tokens()Ljava/util/stream/Stream;": jui.jmethodID,
        @"findAll(Ljava/util/regex/Pattern;)Ljava/util/stream/Stream;": jui.jmethodID,
        @"findAll(Ljava/lang/String;)Ljava/util/stream/Stream;": jui.jmethodID,
        @"next()Ljava/lang/Object;": jui.jmethodID,
        @"<clinit>()V": jui.jmethodID,
    } = undefined;
    pub fn load(env: *jui.JNIEnv) !void {
        struct {
            var runner = std.once(_runner);
            var _env: *jui.JNIEnv = undefined;
            var _err: ?Error = null;

            const Error =
                jui.JNIEnv.FindClassError ||
                jui.JNIEnv.NewReferenceError ||
                jui.JNIEnv.GetFieldIdError ||
                jui.JNIEnv.GetMethodIdError ||
                jui.JNIEnv.GetStaticFieldIdError ||
                jui.JNIEnv.GetStaticMethodIdError;

            fn _load(arg: *jui.JNIEnv) !void {
                _env = arg;
                runner.call();
                if (_err) |e| return e;
            }

            fn _runner() void {
                _run(_env) catch |e| { _err = e; };
            }

            fn _run(inner_env: *jui.JNIEnv) !void {
                const class_local = try inner_env.findClass(classpath);
                class_global = try inner_env.newReference(.global, class_local);
                const class = class_global orelse return error.NoClassDefFoundError;
                // 
                fields = .{
                    .@"buf_Ljava/nio/CharBuffer;" = try inner_env.getFieldId(class, "buf", "Ljava/nio/CharBuffer;"),
                    .@"BUFFER_SIZE_I" = try inner_env.getStaticFieldId(class, "BUFFER_SIZE", "I"),
                    .@"position_I" = try inner_env.getFieldId(class, "position", "I"),
                    .@"matcher_Ljava/util/regex/Matcher;" = try inner_env.getFieldId(class, "matcher", "Ljava/util/regex/Matcher;"),
                    .@"delimPattern_Ljava/util/regex/Pattern;" = try inner_env.getFieldId(class, "delimPattern", "Ljava/util/regex/Pattern;"),
                    .@"hasNextPattern_Ljava/util/regex/Pattern;" = try inner_env.getFieldId(class, "hasNextPattern", "Ljava/util/regex/Pattern;"),
                    .@"hasNextPosition_I" = try inner_env.getFieldId(class, "hasNextPosition", "I"),
                    .@"hasNextResult_Ljava/lang/String;" = try inner_env.getFieldId(class, "hasNextResult", "Ljava/lang/String;"),
                    .@"source_Ljava/lang/Readable;" = try inner_env.getFieldId(class, "source", "Ljava/lang/Readable;"),
                    .@"sourceClosed_Z" = try inner_env.getFieldId(class, "sourceClosed", "Z"),
                    .@"needInput_Z" = try inner_env.getFieldId(class, "needInput", "Z"),
                    .@"skipped_Z" = try inner_env.getFieldId(class, "skipped", "Z"),
                    .@"savedScannerPosition_I" = try inner_env.getFieldId(class, "savedScannerPosition", "I"),
                    .@"typeCache_Ljava/lang/Object;" = try inner_env.getFieldId(class, "typeCache", "Ljava/lang/Object;"),
                    .@"matchValid_Z" = try inner_env.getFieldId(class, "matchValid", "Z"),
                    .@"closed_Z" = try inner_env.getFieldId(class, "closed", "Z"),
                    .@"radix_I" = try inner_env.getFieldId(class, "radix", "I"),
                    .@"defaultRadix_I" = try inner_env.getFieldId(class, "defaultRadix", "I"),
                    .@"locale_Ljava/util/Locale;" = try inner_env.getFieldId(class, "locale", "Ljava/util/Locale;"),
                    .@"patternCache_Ljava/util/Scanner$PatternLRUCache;" = try inner_env.getFieldId(class, "patternCache", "Ljava/util/Scanner$PatternLRUCache;"),
                    .@"lastException_Ljava/io/IOException;" = try inner_env.getFieldId(class, "lastException", "Ljava/io/IOException;"),
                    .@"modCount_I" = try inner_env.getFieldId(class, "modCount", "I"),
                    .@"WHITESPACE_PATTERN_Ljava/util/regex/Pattern;" = try inner_env.getStaticFieldId(class, "WHITESPACE_PATTERN", "Ljava/util/regex/Pattern;"),
                    .@"FIND_ANY_PATTERN_Ljava/util/regex/Pattern;" = try inner_env.getStaticFieldId(class, "FIND_ANY_PATTERN", "Ljava/util/regex/Pattern;"),
                    .@"NON_ASCII_DIGIT_Ljava/util/regex/Pattern;" = try inner_env.getStaticFieldId(class, "NON_ASCII_DIGIT", "Ljava/util/regex/Pattern;"),
                    .@"groupSeparator_Ljava/lang/String;" = try inner_env.getFieldId(class, "groupSeparator", "Ljava/lang/String;"),
                    .@"decimalSeparator_Ljava/lang/String;" = try inner_env.getFieldId(class, "decimalSeparator", "Ljava/lang/String;"),
                    .@"nanString_Ljava/lang/String;" = try inner_env.getFieldId(class, "nanString", "Ljava/lang/String;"),
                    .@"infinityString_Ljava/lang/String;" = try inner_env.getFieldId(class, "infinityString", "Ljava/lang/String;"),
                    .@"positivePrefix_Ljava/lang/String;" = try inner_env.getFieldId(class, "positivePrefix", "Ljava/lang/String;"),
                    .@"negativePrefix_Ljava/lang/String;" = try inner_env.getFieldId(class, "negativePrefix", "Ljava/lang/String;"),
                    .@"positiveSuffix_Ljava/lang/String;" = try inner_env.getFieldId(class, "positiveSuffix", "Ljava/lang/String;"),
                    .@"negativeSuffix_Ljava/lang/String;" = try inner_env.getFieldId(class, "negativeSuffix", "Ljava/lang/String;"),
                    .@"boolPattern_Ljava/util/regex/Pattern;" = try inner_env.getStaticFieldId(class, "boolPattern", "Ljava/util/regex/Pattern;"),
                    .@"BOOLEAN_PATTERN_Ljava/lang/String;" = try inner_env.getStaticFieldId(class, "BOOLEAN_PATTERN", "Ljava/lang/String;"),
                    .@"integerPattern_Ljava/util/regex/Pattern;" = try inner_env.getFieldId(class, "integerPattern", "Ljava/util/regex/Pattern;"),
                    .@"digits_Ljava/lang/String;" = try inner_env.getFieldId(class, "digits", "Ljava/lang/String;"),
                    .@"non0Digit_Ljava/lang/String;" = try inner_env.getFieldId(class, "non0Digit", "Ljava/lang/String;"),
                    .@"SIMPLE_GROUP_INDEX_I" = try inner_env.getFieldId(class, "SIMPLE_GROUP_INDEX", "I"),
                    .@"separatorPattern_Ljava/util/regex/Pattern;" = try inner_env.getStaticFieldId(class, "separatorPattern", "Ljava/util/regex/Pattern;"),
                    .@"linePattern_Ljava/util/regex/Pattern;" = try inner_env.getStaticFieldId(class, "linePattern", "Ljava/util/regex/Pattern;"),
                    .@"LINE_SEPARATOR_PATTERN_Ljava/lang/String;" = try inner_env.getStaticFieldId(class, "LINE_SEPARATOR_PATTERN", "Ljava/lang/String;"),
                    .@"LINE_PATTERN_Ljava/lang/String;" = try inner_env.getStaticFieldId(class, "LINE_PATTERN", "Ljava/lang/String;"),
                    .@"floatPattern_Ljava/util/regex/Pattern;" = try inner_env.getFieldId(class, "floatPattern", "Ljava/util/regex/Pattern;"),
                    .@"decimalPattern_Ljava/util/regex/Pattern;" = try inner_env.getFieldId(class, "decimalPattern", "Ljava/util/regex/Pattern;"),
                    .@"$assertionsDisabled_Z" = try inner_env.getStaticFieldId(class, "$assertionsDisabled", "Z"),
                };
                methods = .{
                    .@"boolPattern()Ljava/util/regex/Pattern;" = try inner_env.getStaticMethodId(class, "boolPattern", "()Ljava/util/regex/Pattern;"),
                    .@"buildIntegerPatternString()Ljava/lang/String;" = try inner_env.getMethodId(class, "buildIntegerPatternString", "()Ljava/lang/String;"),
                    .@"integerPattern()Ljava/util/regex/Pattern;" = try inner_env.getMethodId(class, "integerPattern", "()Ljava/util/regex/Pattern;"),
                    .@"separatorPattern()Ljava/util/regex/Pattern;" = try inner_env.getStaticMethodId(class, "separatorPattern", "()Ljava/util/regex/Pattern;"),
                    .@"linePattern()Ljava/util/regex/Pattern;" = try inner_env.getStaticMethodId(class, "linePattern", "()Ljava/util/regex/Pattern;"),
                    .@"buildFloatAndDecimalPattern()V" = try inner_env.getMethodId(class, "buildFloatAndDecimalPattern", "()V"),
                    .@"floatPattern()Ljava/util/regex/Pattern;" = try inner_env.getMethodId(class, "floatPattern", "()Ljava/util/regex/Pattern;"),
                    .@"decimalPattern()Ljava/util/regex/Pattern;" = try inner_env.getMethodId(class, "decimalPattern", "()Ljava/util/regex/Pattern;"),
                    .@"<init>(Ljava/lang/Readable;Ljava/util/regex/Pattern;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/lang/Readable;Ljava/util/regex/Pattern;)V"),
                    .@"<init>(Ljava/lang/Readable;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/lang/Readable;)V"),
                    .@"<init>(Ljava/io/InputStream;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/io/InputStream;)V"),
                    .@"<init>(Ljava/io/InputStream;Ljava/lang/String;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/io/InputStream;Ljava/lang/String;)V"),
                    .@"<init>(Ljava/io/InputStream;Ljava/nio/charset/Charset;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/io/InputStream;Ljava/nio/charset/Charset;)V"),
                    .@"toCharset(Ljava/lang/String;)Ljava/nio/charset/Charset;" = try inner_env.getStaticMethodId(class, "toCharset", "(Ljava/lang/String;)Ljava/nio/charset/Charset;"),
                    .@"makeReadable(Ljava/nio/file/Path;Ljava/nio/charset/Charset;)Ljava/lang/Readable;" = try inner_env.getStaticMethodId(class, "makeReadable", "(Ljava/nio/file/Path;Ljava/nio/charset/Charset;)Ljava/lang/Readable;"),
                    .@"makeReadable(Ljava/io/InputStream;Ljava/nio/charset/Charset;)Ljava/lang/Readable;" = try inner_env.getStaticMethodId(class, "makeReadable", "(Ljava/io/InputStream;Ljava/nio/charset/Charset;)Ljava/lang/Readable;"),
                    .@"<init>(Ljava/io/File;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/io/File;)V"),
                    .@"<init>(Ljava/io/File;Ljava/lang/String;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/io/File;Ljava/lang/String;)V"),
                    .@"<init>(Ljava/io/File;Ljava/nio/charset/Charset;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/io/File;Ljava/nio/charset/Charset;)V"),
                    .@"<init>(Ljava/io/File;Ljava/nio/charset/CharsetDecoder;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/io/File;Ljava/nio/charset/CharsetDecoder;)V"),
                    .@"toDecoder(Ljava/lang/String;)Ljava/nio/charset/CharsetDecoder;" = try inner_env.getStaticMethodId(class, "toDecoder", "(Ljava/lang/String;)Ljava/nio/charset/CharsetDecoder;"),
                    .@"makeReadable(Ljava/nio/channels/ReadableByteChannel;Ljava/nio/charset/CharsetDecoder;)Ljava/lang/Readable;" = try inner_env.getStaticMethodId(class, "makeReadable", "(Ljava/nio/channels/ReadableByteChannel;Ljava/nio/charset/CharsetDecoder;)Ljava/lang/Readable;"),
                    .@"makeReadable(Ljava/nio/channels/ReadableByteChannel;Ljava/nio/charset/Charset;)Ljava/lang/Readable;" = try inner_env.getStaticMethodId(class, "makeReadable", "(Ljava/nio/channels/ReadableByteChannel;Ljava/nio/charset/Charset;)Ljava/lang/Readable;"),
                    .@"<init>(Ljava/nio/file/Path;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/nio/file/Path;)V"),
                    .@"<init>(Ljava/nio/file/Path;Ljava/lang/String;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/nio/file/Path;Ljava/lang/String;)V"),
                    .@"<init>(Ljava/nio/file/Path;Ljava/nio/charset/Charset;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/nio/file/Path;Ljava/nio/charset/Charset;)V"),
                    .@"<init>(Ljava/lang/String;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/lang/String;)V"),
                    .@"<init>(Ljava/nio/channels/ReadableByteChannel;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/nio/channels/ReadableByteChannel;)V"),
                    .@"makeReadable(Ljava/nio/channels/ReadableByteChannel;)Ljava/lang/Readable;" = try inner_env.getStaticMethodId(class, "makeReadable", "(Ljava/nio/channels/ReadableByteChannel;)Ljava/lang/Readable;"),
                    .@"<init>(Ljava/nio/channels/ReadableByteChannel;Ljava/lang/String;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/nio/channels/ReadableByteChannel;Ljava/lang/String;)V"),
                    .@"<init>(Ljava/nio/channels/ReadableByteChannel;Ljava/nio/charset/Charset;)V" = try inner_env.getMethodId(class, "<init>", "(Ljava/nio/channels/ReadableByteChannel;Ljava/nio/charset/Charset;)V"),
                    .@"saveState()V" = try inner_env.getMethodId(class, "saveState", "()V"),
                    .@"revertState()V" = try inner_env.getMethodId(class, "revertState", "()V"),
                    .@"revertState(Z)Z" = try inner_env.getMethodId(class, "revertState", "(Z)Z"),
                    .@"cacheResult()V" = try inner_env.getMethodId(class, "cacheResult", "()V"),
                    .@"cacheResult(Ljava/lang/String;)V" = try inner_env.getMethodId(class, "cacheResult", "(Ljava/lang/String;)V"),
                    .@"clearCaches()V" = try inner_env.getMethodId(class, "clearCaches", "()V"),
                    .@"getCachedResult()Ljava/lang/String;" = try inner_env.getMethodId(class, "getCachedResult", "()Ljava/lang/String;"),
                    .@"useTypeCache()V" = try inner_env.getMethodId(class, "useTypeCache", "()V"),
                    .@"readInput()V" = try inner_env.getMethodId(class, "readInput", "()V"),
                    .@"makeSpace()Z" = try inner_env.getMethodId(class, "makeSpace", "()Z"),
                    .@"translateSavedIndexes(I)V" = try inner_env.getMethodId(class, "translateSavedIndexes", "(I)V"),
                    .@"throwFor()V" = try inner_env.getMethodId(class, "throwFor", "()V"),
                    .@"hasTokenInBuffer()Z" = try inner_env.getMethodId(class, "hasTokenInBuffer", "()Z"),
                    .@"getCompleteTokenInBuffer(Ljava/util/regex/Pattern;)Ljava/lang/String;" = try inner_env.getMethodId(class, "getCompleteTokenInBuffer", "(Ljava/util/regex/Pattern;)Ljava/lang/String;"),
                    .@"findPatternInBuffer(Ljava/util/regex/Pattern;I)Z" = try inner_env.getMethodId(class, "findPatternInBuffer", "(Ljava/util/regex/Pattern;I)Z"),
                    .@"matchPatternInBuffer(Ljava/util/regex/Pattern;)Z" = try inner_env.getMethodId(class, "matchPatternInBuffer", "(Ljava/util/regex/Pattern;)Z"),
                    .@"ensureOpen()V" = try inner_env.getMethodId(class, "ensureOpen", "()V"),
                    .@"close()V" = try inner_env.getMethodId(class, "close", "()V"),
                    .@"ioException()Ljava/io/IOException;" = try inner_env.getMethodId(class, "ioException", "()Ljava/io/IOException;"),
                    .@"delimiter()Ljava/util/regex/Pattern;" = try inner_env.getMethodId(class, "delimiter", "()Ljava/util/regex/Pattern;"),
                    .@"useDelimiter(Ljava/util/regex/Pattern;)Ljava/util/Scanner;" = try inner_env.getMethodId(class, "useDelimiter", "(Ljava/util/regex/Pattern;)Ljava/util/Scanner;"),
                    .@"useDelimiter(Ljava/lang/String;)Ljava/util/Scanner;" = try inner_env.getMethodId(class, "useDelimiter", "(Ljava/lang/String;)Ljava/util/Scanner;"),
                    .@"locale()Ljava/util/Locale;" = try inner_env.getMethodId(class, "locale", "()Ljava/util/Locale;"),
                    .@"useLocale(Ljava/util/Locale;)Ljava/util/Scanner;" = try inner_env.getMethodId(class, "useLocale", "(Ljava/util/Locale;)Ljava/util/Scanner;"),
                    .@"radix()I" = try inner_env.getMethodId(class, "radix", "()I"),
                    .@"useRadix(I)Ljava/util/Scanner;" = try inner_env.getMethodId(class, "useRadix", "(I)Ljava/util/Scanner;"),
                    .@"setRadix(I)V" = try inner_env.getMethodId(class, "setRadix", "(I)V"),
                    .@"match()Ljava/util/regex/MatchResult;" = try inner_env.getMethodId(class, "match", "()Ljava/util/regex/MatchResult;"),
                    .@"toString()Ljava/lang/String;" = try inner_env.getMethodId(class, "toString", "()Ljava/lang/String;"),
                    .@"hasNext()Z" = try inner_env.getMethodId(class, "hasNext", "()Z"),
                    .@"next()Ljava/lang/String;" = try inner_env.getMethodId(class, "next", "()Ljava/lang/String;"),
                    .@"remove()V" = try inner_env.getMethodId(class, "remove", "()V"),
                    .@"hasNext(Ljava/lang/String;)Z" = try inner_env.getMethodId(class, "hasNext", "(Ljava/lang/String;)Z"),
                    .@"next(Ljava/lang/String;)Ljava/lang/String;" = try inner_env.getMethodId(class, "next", "(Ljava/lang/String;)Ljava/lang/String;"),
                    .@"hasNext(Ljava/util/regex/Pattern;)Z" = try inner_env.getMethodId(class, "hasNext", "(Ljava/util/regex/Pattern;)Z"),
                    .@"next(Ljava/util/regex/Pattern;)Ljava/lang/String;" = try inner_env.getMethodId(class, "next", "(Ljava/util/regex/Pattern;)Ljava/lang/String;"),
                    .@"hasNextLine()Z" = try inner_env.getMethodId(class, "hasNextLine", "()Z"),
                    .@"nextLine()Ljava/lang/String;" = try inner_env.getMethodId(class, "nextLine", "()Ljava/lang/String;"),
                    .@"findInLine(Ljava/lang/String;)Ljava/lang/String;" = try inner_env.getMethodId(class, "findInLine", "(Ljava/lang/String;)Ljava/lang/String;"),
                    .@"findInLine(Ljava/util/regex/Pattern;)Ljava/lang/String;" = try inner_env.getMethodId(class, "findInLine", "(Ljava/util/regex/Pattern;)Ljava/lang/String;"),
                    .@"findWithinHorizon(Ljava/lang/String;I)Ljava/lang/String;" = try inner_env.getMethodId(class, "findWithinHorizon", "(Ljava/lang/String;I)Ljava/lang/String;"),
                    .@"findWithinHorizon(Ljava/util/regex/Pattern;I)Ljava/lang/String;" = try inner_env.getMethodId(class, "findWithinHorizon", "(Ljava/util/regex/Pattern;I)Ljava/lang/String;"),
                    .@"skip(Ljava/util/regex/Pattern;)Ljava/util/Scanner;" = try inner_env.getMethodId(class, "skip", "(Ljava/util/regex/Pattern;)Ljava/util/Scanner;"),
                    .@"skip(Ljava/lang/String;)Ljava/util/Scanner;" = try inner_env.getMethodId(class, "skip", "(Ljava/lang/String;)Ljava/util/Scanner;"),
                    .@"hasNextBoolean()Z" = try inner_env.getMethodId(class, "hasNextBoolean", "()Z"),
                    .@"nextBoolean()Z" = try inner_env.getMethodId(class, "nextBoolean", "()Z"),
                    .@"hasNextByte()Z" = try inner_env.getMethodId(class, "hasNextByte", "()Z"),
                    .@"hasNextByte(I)Z" = try inner_env.getMethodId(class, "hasNextByte", "(I)Z"),
                    .@"nextByte()B" = try inner_env.getMethodId(class, "nextByte", "()B"),
                    .@"nextByte(I)B" = try inner_env.getMethodId(class, "nextByte", "(I)B"),
                    .@"hasNextShort()Z" = try inner_env.getMethodId(class, "hasNextShort", "()Z"),
                    .@"hasNextShort(I)Z" = try inner_env.getMethodId(class, "hasNextShort", "(I)Z"),
                    .@"nextShort()S" = try inner_env.getMethodId(class, "nextShort", "()S"),
                    .@"nextShort(I)S" = try inner_env.getMethodId(class, "nextShort", "(I)S"),
                    .@"hasNextInt()Z" = try inner_env.getMethodId(class, "hasNextInt", "()Z"),
                    .@"hasNextInt(I)Z" = try inner_env.getMethodId(class, "hasNextInt", "(I)Z"),
                    .@"processIntegerToken(Ljava/lang/String;)Ljava/lang/String;" = try inner_env.getMethodId(class, "processIntegerToken", "(Ljava/lang/String;)Ljava/lang/String;"),
                    .@"nextInt()I" = try inner_env.getMethodId(class, "nextInt", "()I"),
                    .@"nextInt(I)I" = try inner_env.getMethodId(class, "nextInt", "(I)I"),
                    .@"hasNextLong()Z" = try inner_env.getMethodId(class, "hasNextLong", "()Z"),
                    .@"hasNextLong(I)Z" = try inner_env.getMethodId(class, "hasNextLong", "(I)Z"),
                    .@"nextLong()J" = try inner_env.getMethodId(class, "nextLong", "()J"),
                    .@"nextLong(I)J" = try inner_env.getMethodId(class, "nextLong", "(I)J"),
                    .@"processFloatToken(Ljava/lang/String;)Ljava/lang/String;" = try inner_env.getMethodId(class, "processFloatToken", "(Ljava/lang/String;)Ljava/lang/String;"),
                    .@"hasNextFloat()Z" = try inner_env.getMethodId(class, "hasNextFloat", "()Z"),
                    .@"nextFloat()F" = try inner_env.getMethodId(class, "nextFloat", "()F"),
                    .@"hasNextDouble()Z" = try inner_env.getMethodId(class, "hasNextDouble", "()Z"),
                    .@"nextDouble()D" = try inner_env.getMethodId(class, "nextDouble", "()D"),
                    .@"hasNextBigInteger()Z" = try inner_env.getMethodId(class, "hasNextBigInteger", "()Z"),
                    .@"hasNextBigInteger(I)Z" = try inner_env.getMethodId(class, "hasNextBigInteger", "(I)Z"),
                    .@"nextBigInteger()Ljava/math/BigInteger;" = try inner_env.getMethodId(class, "nextBigInteger", "()Ljava/math/BigInteger;"),
                    .@"nextBigInteger(I)Ljava/math/BigInteger;" = try inner_env.getMethodId(class, "nextBigInteger", "(I)Ljava/math/BigInteger;"),
                    .@"hasNextBigDecimal()Z" = try inner_env.getMethodId(class, "hasNextBigDecimal", "()Z"),
                    .@"nextBigDecimal()Ljava/math/BigDecimal;" = try inner_env.getMethodId(class, "nextBigDecimal", "()Ljava/math/BigDecimal;"),
                    .@"reset()Ljava/util/Scanner;" = try inner_env.getMethodId(class, "reset", "()Ljava/util/Scanner;"),
                    .@"tokens()Ljava/util/stream/Stream;" = try inner_env.getMethodId(class, "tokens", "()Ljava/util/stream/Stream;"),
                    .@"findAll(Ljava/util/regex/Pattern;)Ljava/util/stream/Stream;" = try inner_env.getMethodId(class, "findAll", "(Ljava/util/regex/Pattern;)Ljava/util/stream/Stream;"),
                    .@"findAll(Ljava/lang/String;)Ljava/util/stream/Stream;" = try inner_env.getMethodId(class, "findAll", "(Ljava/lang/String;)Ljava/util/stream/Stream;"),
                    .@"next()Ljava/lang/Object;" = try inner_env.getMethodId(class, "next", "()Ljava/lang/Object;"),
                    .@"<clinit>()V" = try inner_env.getStaticMethodId(class, "<clinit>", "()V"),
                };

            }
        }._load(env) catch |e| return e;
    }
    pub fn @"get_buf_Ljava/nio/CharBuffer;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"buf_Ljava/nio/CharBuffer;");
    }
    pub fn @"set_buf_Ljava/nio/CharBuffer;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"buf_Ljava/nio/CharBuffer;", arg);
    }
    pub fn @"get_BUFFER_SIZE_I"(env: *jui.JNIEnv) !jui.jint {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.getStaticField(.int, class, fields.@"BUFFER_SIZE_I");
    }
    pub fn @"get_position_I"(self: *@This(), env: *jui.JNIEnv) !jui.jint {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.int, @ptrCast(jui.jobject, self), fields.@"position_I");
    }
    pub fn @"set_position_I"(self: *@This(), env: *jui.JNIEnv, arg: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.int, @ptrCast(jui.jobject, self), fields.@"position_I", arg);
    }
    pub fn @"get_matcher_Ljava/util/regex/Matcher;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"matcher_Ljava/util/regex/Matcher;");
    }
    pub fn @"set_matcher_Ljava/util/regex/Matcher;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"matcher_Ljava/util/regex/Matcher;", arg);
    }
    pub fn @"get_delimPattern_Ljava/util/regex/Pattern;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"delimPattern_Ljava/util/regex/Pattern;");
    }
    pub fn @"set_delimPattern_Ljava/util/regex/Pattern;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"delimPattern_Ljava/util/regex/Pattern;", arg);
    }
    pub fn @"get_hasNextPattern_Ljava/util/regex/Pattern;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"hasNextPattern_Ljava/util/regex/Pattern;");
    }
    pub fn @"set_hasNextPattern_Ljava/util/regex/Pattern;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"hasNextPattern_Ljava/util/regex/Pattern;", arg);
    }
    pub fn @"get_hasNextPosition_I"(self: *@This(), env: *jui.JNIEnv) !jui.jint {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.int, @ptrCast(jui.jobject, self), fields.@"hasNextPosition_I");
    }
    pub fn @"set_hasNextPosition_I"(self: *@This(), env: *jui.JNIEnv, arg: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.int, @ptrCast(jui.jobject, self), fields.@"hasNextPosition_I", arg);
    }
    pub fn @"get_hasNextResult_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"hasNextResult_Ljava/lang/String;");
    }
    pub fn @"set_hasNextResult_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"hasNextResult_Ljava/lang/String;", arg);
    }
    pub fn @"get_source_Ljava/lang/Readable;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"source_Ljava/lang/Readable;");
    }
    pub fn @"set_source_Ljava/lang/Readable;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"source_Ljava/lang/Readable;", arg);
    }
    pub fn @"get_sourceClosed_Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.boolean, @ptrCast(jui.jobject, self), fields.@"sourceClosed_Z");
    }
    pub fn @"set_sourceClosed_Z"(self: *@This(), env: *jui.JNIEnv, arg: jui.jboolean) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.boolean, @ptrCast(jui.jobject, self), fields.@"sourceClosed_Z", arg);
    }
    pub fn @"get_needInput_Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.boolean, @ptrCast(jui.jobject, self), fields.@"needInput_Z");
    }
    pub fn @"set_needInput_Z"(self: *@This(), env: *jui.JNIEnv, arg: jui.jboolean) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.boolean, @ptrCast(jui.jobject, self), fields.@"needInput_Z", arg);
    }
    pub fn @"get_skipped_Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.boolean, @ptrCast(jui.jobject, self), fields.@"skipped_Z");
    }
    pub fn @"set_skipped_Z"(self: *@This(), env: *jui.JNIEnv, arg: jui.jboolean) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.boolean, @ptrCast(jui.jobject, self), fields.@"skipped_Z", arg);
    }
    pub fn @"get_savedScannerPosition_I"(self: *@This(), env: *jui.JNIEnv) !jui.jint {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.int, @ptrCast(jui.jobject, self), fields.@"savedScannerPosition_I");
    }
    pub fn @"set_savedScannerPosition_I"(self: *@This(), env: *jui.JNIEnv, arg: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.int, @ptrCast(jui.jobject, self), fields.@"savedScannerPosition_I", arg);
    }
    pub fn @"get_typeCache_Ljava/lang/Object;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"typeCache_Ljava/lang/Object;");
    }
    pub fn @"set_typeCache_Ljava/lang/Object;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"typeCache_Ljava/lang/Object;", arg);
    }
    pub fn @"get_matchValid_Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.boolean, @ptrCast(jui.jobject, self), fields.@"matchValid_Z");
    }
    pub fn @"set_matchValid_Z"(self: *@This(), env: *jui.JNIEnv, arg: jui.jboolean) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.boolean, @ptrCast(jui.jobject, self), fields.@"matchValid_Z", arg);
    }
    pub fn @"get_closed_Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.boolean, @ptrCast(jui.jobject, self), fields.@"closed_Z");
    }
    pub fn @"set_closed_Z"(self: *@This(), env: *jui.JNIEnv, arg: jui.jboolean) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.boolean, @ptrCast(jui.jobject, self), fields.@"closed_Z", arg);
    }
    pub fn @"get_radix_I"(self: *@This(), env: *jui.JNIEnv) !jui.jint {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.int, @ptrCast(jui.jobject, self), fields.@"radix_I");
    }
    pub fn @"set_radix_I"(self: *@This(), env: *jui.JNIEnv, arg: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.int, @ptrCast(jui.jobject, self), fields.@"radix_I", arg);
    }
    pub fn @"get_defaultRadix_I"(self: *@This(), env: *jui.JNIEnv) !jui.jint {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.int, @ptrCast(jui.jobject, self), fields.@"defaultRadix_I");
    }
    pub fn @"set_defaultRadix_I"(self: *@This(), env: *jui.JNIEnv, arg: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.int, @ptrCast(jui.jobject, self), fields.@"defaultRadix_I", arg);
    }
    pub fn @"get_locale_Ljava/util/Locale;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"locale_Ljava/util/Locale;");
    }
    pub fn @"set_locale_Ljava/util/Locale;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"locale_Ljava/util/Locale;", arg);
    }
    pub fn @"get_patternCache_Ljava/util/Scanner$PatternLRUCache;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"patternCache_Ljava/util/Scanner$PatternLRUCache;");
    }
    pub fn @"set_patternCache_Ljava/util/Scanner$PatternLRUCache;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"patternCache_Ljava/util/Scanner$PatternLRUCache;", arg);
    }
    pub fn @"get_lastException_Ljava/io/IOException;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"lastException_Ljava/io/IOException;");
    }
    pub fn @"set_lastException_Ljava/io/IOException;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"lastException_Ljava/io/IOException;", arg);
    }
    pub fn @"get_modCount_I"(self: *@This(), env: *jui.JNIEnv) !jui.jint {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.int, @ptrCast(jui.jobject, self), fields.@"modCount_I");
    }
    pub fn @"set_modCount_I"(self: *@This(), env: *jui.JNIEnv, arg: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.int, @ptrCast(jui.jobject, self), fields.@"modCount_I", arg);
    }
    pub fn @"get_WHITESPACE_PATTERN_Ljava/util/regex/Pattern;"(env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.getStaticField(.object, class, fields.@"WHITESPACE_PATTERN_Ljava/util/regex/Pattern;");
    }
    pub fn @"set_WHITESPACE_PATTERN_Ljava/util/regex/Pattern;"(env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        try env.callStaticField(.object, class, fields.@"WHITESPACE_PATTERN_Ljava/util/regex/Pattern;", arg);
    }
    pub fn @"get_FIND_ANY_PATTERN_Ljava/util/regex/Pattern;"(env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.getStaticField(.object, class, fields.@"FIND_ANY_PATTERN_Ljava/util/regex/Pattern;");
    }
    pub fn @"set_FIND_ANY_PATTERN_Ljava/util/regex/Pattern;"(env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        try env.callStaticField(.object, class, fields.@"FIND_ANY_PATTERN_Ljava/util/regex/Pattern;", arg);
    }
    pub fn @"get_NON_ASCII_DIGIT_Ljava/util/regex/Pattern;"(env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.getStaticField(.object, class, fields.@"NON_ASCII_DIGIT_Ljava/util/regex/Pattern;");
    }
    pub fn @"set_NON_ASCII_DIGIT_Ljava/util/regex/Pattern;"(env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        try env.callStaticField(.object, class, fields.@"NON_ASCII_DIGIT_Ljava/util/regex/Pattern;", arg);
    }
    pub fn @"get_groupSeparator_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"groupSeparator_Ljava/lang/String;");
    }
    pub fn @"set_groupSeparator_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"groupSeparator_Ljava/lang/String;", arg);
    }
    pub fn @"get_decimalSeparator_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"decimalSeparator_Ljava/lang/String;");
    }
    pub fn @"set_decimalSeparator_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"decimalSeparator_Ljava/lang/String;", arg);
    }
    pub fn @"get_nanString_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"nanString_Ljava/lang/String;");
    }
    pub fn @"set_nanString_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"nanString_Ljava/lang/String;", arg);
    }
    pub fn @"get_infinityString_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"infinityString_Ljava/lang/String;");
    }
    pub fn @"set_infinityString_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"infinityString_Ljava/lang/String;", arg);
    }
    pub fn @"get_positivePrefix_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"positivePrefix_Ljava/lang/String;");
    }
    pub fn @"set_positivePrefix_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"positivePrefix_Ljava/lang/String;", arg);
    }
    pub fn @"get_negativePrefix_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"negativePrefix_Ljava/lang/String;");
    }
    pub fn @"set_negativePrefix_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"negativePrefix_Ljava/lang/String;", arg);
    }
    pub fn @"get_positiveSuffix_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"positiveSuffix_Ljava/lang/String;");
    }
    pub fn @"set_positiveSuffix_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"positiveSuffix_Ljava/lang/String;", arg);
    }
    pub fn @"get_negativeSuffix_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"negativeSuffix_Ljava/lang/String;");
    }
    pub fn @"set_negativeSuffix_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"negativeSuffix_Ljava/lang/String;", arg);
    }
    pub fn @"get_boolPattern_Ljava/util/regex/Pattern;"(env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.getStaticField(.object, class, fields.@"boolPattern_Ljava/util/regex/Pattern;");
    }
    pub fn @"set_boolPattern_Ljava/util/regex/Pattern;"(env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        try env.callStaticField(.object, class, fields.@"boolPattern_Ljava/util/regex/Pattern;", arg);
    }
    pub fn @"get_BOOLEAN_PATTERN_Ljava/lang/String;"(env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.getStaticField(.object, class, fields.@"BOOLEAN_PATTERN_Ljava/lang/String;");
    }
    pub fn @"get_integerPattern_Ljava/util/regex/Pattern;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"integerPattern_Ljava/util/regex/Pattern;");
    }
    pub fn @"set_integerPattern_Ljava/util/regex/Pattern;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"integerPattern_Ljava/util/regex/Pattern;", arg);
    }
    pub fn @"get_digits_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"digits_Ljava/lang/String;");
    }
    pub fn @"set_digits_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"digits_Ljava/lang/String;", arg);
    }
    pub fn @"get_non0Digit_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"non0Digit_Ljava/lang/String;");
    }
    pub fn @"set_non0Digit_Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"non0Digit_Ljava/lang/String;", arg);
    }
    pub fn @"get_SIMPLE_GROUP_INDEX_I"(self: *@This(), env: *jui.JNIEnv) !jui.jint {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.int, @ptrCast(jui.jobject, self), fields.@"SIMPLE_GROUP_INDEX_I");
    }
    pub fn @"set_SIMPLE_GROUP_INDEX_I"(self: *@This(), env: *jui.JNIEnv, arg: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.int, @ptrCast(jui.jobject, self), fields.@"SIMPLE_GROUP_INDEX_I", arg);
    }
    pub fn @"get_separatorPattern_Ljava/util/regex/Pattern;"(env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.getStaticField(.object, class, fields.@"separatorPattern_Ljava/util/regex/Pattern;");
    }
    pub fn @"set_separatorPattern_Ljava/util/regex/Pattern;"(env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        try env.callStaticField(.object, class, fields.@"separatorPattern_Ljava/util/regex/Pattern;", arg);
    }
    pub fn @"get_linePattern_Ljava/util/regex/Pattern;"(env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.getStaticField(.object, class, fields.@"linePattern_Ljava/util/regex/Pattern;");
    }
    pub fn @"set_linePattern_Ljava/util/regex/Pattern;"(env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        try env.callStaticField(.object, class, fields.@"linePattern_Ljava/util/regex/Pattern;", arg);
    }
    pub fn @"get_LINE_SEPARATOR_PATTERN_Ljava/lang/String;"(env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.getStaticField(.object, class, fields.@"LINE_SEPARATOR_PATTERN_Ljava/lang/String;");
    }
    pub fn @"get_LINE_PATTERN_Ljava/lang/String;"(env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.getStaticField(.object, class, fields.@"LINE_PATTERN_Ljava/lang/String;");
    }
    pub fn @"get_floatPattern_Ljava/util/regex/Pattern;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"floatPattern_Ljava/util/regex/Pattern;");
    }
    pub fn @"set_floatPattern_Ljava/util/regex/Pattern;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"floatPattern_Ljava/util/regex/Pattern;", arg);
    }
    pub fn @"get_decimalPattern_Ljava/util/regex/Pattern;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.getField(.object, @ptrCast(jui.jobject, self), fields.@"decimalPattern_Ljava/util/regex/Pattern;");
    }
    pub fn @"set_decimalPattern_Ljava/util/regex/Pattern;"(self: *@This(), env: *jui.JNIEnv, arg: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        try env.callField(.object, @ptrCast(jui.jobject, self), fields.@"decimalPattern_Ljava/util/regex/Pattern;", arg);
    }
    pub fn @"get_$assertionsDisabled_Z"(env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.getStaticField(.boolean, class, fields.@"$assertionsDisabled_Z");
    }
    pub fn @"boolPattern()Ljava/util/regex/Pattern;"(env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.callStaticMethod(.object, class, methods.@"boolPattern()Ljava/util/regex/Pattern;", null);
    }
    pub fn @"buildIntegerPatternString()Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"buildIntegerPatternString()Ljava/lang/String;", null);
    }
    pub fn @"integerPattern()Ljava/util/regex/Pattern;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"integerPattern()Ljava/util/regex/Pattern;", null);
    }
    pub fn @"separatorPattern()Ljava/util/regex/Pattern;"(env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.callStaticMethod(.object, class, methods.@"separatorPattern()Ljava/util/regex/Pattern;", null);
    }
    pub fn @"linePattern()Ljava/util/regex/Pattern;"(env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.callStaticMethod(.object, class, methods.@"linePattern()Ljava/util/regex/Pattern;", null);
    }
    pub fn @"buildFloatAndDecimalPattern()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"buildFloatAndDecimalPattern()V", null);
    }
    pub fn @"floatPattern()Ljava/util/regex/Pattern;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"floatPattern()Ljava/util/regex/Pattern;", null);
    }
    pub fn @"decimalPattern()Ljava/util/regex/Pattern;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"decimalPattern()Ljava/util/regex/Pattern;", null);
    }
    pub fn @"<init>(Ljava/lang/Readable;Ljava/util/regex/Pattern;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/lang/Readable;Ljava/util/regex/Pattern;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"<init>(Ljava/lang/Readable;)V"(env: *jui.JNIEnv, arg0: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/lang/Readable;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)}));
    }
    pub fn @"<init>(Ljava/io/InputStream;)V"(env: *jui.JNIEnv, arg0: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/io/InputStream;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)}));
    }
    pub fn @"<init>(Ljava/io/InputStream;Ljava/lang/String;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/io/InputStream;Ljava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"<init>(Ljava/io/InputStream;Ljava/nio/charset/Charset;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/io/InputStream;Ljava/nio/charset/Charset;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"toCharset(Ljava/lang/String;)Ljava/nio/charset/Charset;"(env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.callStaticMethod(.object, class, methods.@"toCharset(Ljava/lang/String;)Ljava/nio/charset/Charset;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"makeReadable(Ljava/nio/file/Path;Ljava/nio/charset/Charset;)Ljava/lang/Readable;"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.callStaticMethod(.object, class, methods.@"makeReadable(Ljava/nio/file/Path;Ljava/nio/charset/Charset;)Ljava/lang/Readable;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)});
    }
    pub fn @"makeReadable(Ljava/io/InputStream;Ljava/nio/charset/Charset;)Ljava/lang/Readable;"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.callStaticMethod(.object, class, methods.@"makeReadable(Ljava/io/InputStream;Ljava/nio/charset/Charset;)Ljava/lang/Readable;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)});
    }
    pub fn @"<init>(Ljava/io/File;)V"(env: *jui.JNIEnv, arg0: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/io/File;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)}));
    }
    pub fn @"<init>(Ljava/io/File;Ljava/lang/String;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/io/File;Ljava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"<init>(Ljava/io/File;Ljava/nio/charset/Charset;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/io/File;Ljava/nio/charset/Charset;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"<init>(Ljava/io/File;Ljava/nio/charset/CharsetDecoder;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/io/File;Ljava/nio/charset/CharsetDecoder;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"toDecoder(Ljava/lang/String;)Ljava/nio/charset/CharsetDecoder;"(env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.callStaticMethod(.object, class, methods.@"toDecoder(Ljava/lang/String;)Ljava/nio/charset/CharsetDecoder;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"makeReadable(Ljava/nio/channels/ReadableByteChannel;Ljava/nio/charset/CharsetDecoder;)Ljava/lang/Readable;"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.callStaticMethod(.object, class, methods.@"makeReadable(Ljava/nio/channels/ReadableByteChannel;Ljava/nio/charset/CharsetDecoder;)Ljava/lang/Readable;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)});
    }
    pub fn @"makeReadable(Ljava/nio/channels/ReadableByteChannel;Ljava/nio/charset/Charset;)Ljava/lang/Readable;"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.callStaticMethod(.object, class, methods.@"makeReadable(Ljava/nio/channels/ReadableByteChannel;Ljava/nio/charset/Charset;)Ljava/lang/Readable;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)});
    }
    pub fn @"<init>(Ljava/nio/file/Path;)V"(env: *jui.JNIEnv, arg0: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/nio/file/Path;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)}));
    }
    pub fn @"<init>(Ljava/nio/file/Path;Ljava/lang/String;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/nio/file/Path;Ljava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"<init>(Ljava/nio/file/Path;Ljava/nio/charset/Charset;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/nio/file/Path;Ljava/nio/charset/Charset;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"<init>(Ljava/lang/String;)V"(env: *jui.JNIEnv, arg0: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)}));
    }
    pub fn @"<init>(Ljava/nio/channels/ReadableByteChannel;)V"(env: *jui.JNIEnv, arg0: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/nio/channels/ReadableByteChannel;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)}));
    }
    pub fn @"makeReadable(Ljava/nio/channels/ReadableByteChannel;)Ljava/lang/Readable;"(env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.callStaticMethod(.object, class, methods.@"makeReadable(Ljava/nio/channels/ReadableByteChannel;)Ljava/lang/Readable;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"<init>(Ljava/nio/channels/ReadableByteChannel;Ljava/lang/String;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/nio/channels/ReadableByteChannel;Ljava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"<init>(Ljava/nio/channels/ReadableByteChannel;Ljava/nio/charset/Charset;)V"(env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jobject) !*@This() {
        try load(env);
        const class = class_global orelse return error.ClassNotLoaded;
        return @ptrCast(*@This(), try env.newObject(class, methods.@"<init>(Ljava/nio/channels/ReadableByteChannel;Ljava/nio/charset/Charset;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)}));
    }
    pub fn @"saveState()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"saveState()V", null);
    }
    pub fn @"revertState()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"revertState()V", null);
    }
    pub fn @"revertState(Z)Z"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jboolean) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"revertState(Z)Z", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"cacheResult()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"cacheResult()V", null);
    }
    pub fn @"cacheResult(Ljava/lang/String;)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"cacheResult(Ljava/lang/String;)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"clearCaches()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"clearCaches()V", null);
    }
    pub fn @"getCachedResult()Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"getCachedResult()Ljava/lang/String;", null);
    }
    pub fn @"useTypeCache()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"useTypeCache()V", null);
    }
    pub fn @"readInput()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"readInput()V", null);
    }
    pub fn @"makeSpace()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"makeSpace()Z", null);
    }
    pub fn @"translateSavedIndexes(I)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"translateSavedIndexes(I)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"throwFor()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"throwFor()V", null);
    }
    pub fn @"hasTokenInBuffer()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasTokenInBuffer()Z", null);
    }
    pub fn @"getCompleteTokenInBuffer(Ljava/util/regex/Pattern;)Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"getCompleteTokenInBuffer(Ljava/util/regex/Pattern;)Ljava/lang/String;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"findPatternInBuffer(Ljava/util/regex/Pattern;I)Z"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jint) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"findPatternInBuffer(Ljava/util/regex/Pattern;I)Z", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)});
    }
    pub fn @"matchPatternInBuffer(Ljava/util/regex/Pattern;)Z"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"matchPatternInBuffer(Ljava/util/regex/Pattern;)Z", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"ensureOpen()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"ensureOpen()V", null);
    }
    pub fn @"close()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"close()V", null);
    }
    pub fn @"ioException()Ljava/io/IOException;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"ioException()Ljava/io/IOException;", null);
    }
    pub fn @"delimiter()Ljava/util/regex/Pattern;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"delimiter()Ljava/util/regex/Pattern;", null);
    }
    pub fn @"useDelimiter(Ljava/util/regex/Pattern;)Ljava/util/Scanner;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"useDelimiter(Ljava/util/regex/Pattern;)Ljava/util/Scanner;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"useDelimiter(Ljava/lang/String;)Ljava/util/Scanner;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"useDelimiter(Ljava/lang/String;)Ljava/util/Scanner;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"locale()Ljava/util/Locale;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"locale()Ljava/util/Locale;", null);
    }
    pub fn @"useLocale(Ljava/util/Locale;)Ljava/util/Scanner;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"useLocale(Ljava/util/Locale;)Ljava/util/Scanner;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"radix()I"(self: *@This(), env: *jui.JNIEnv) !jui.jint {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.int, @ptrCast(jui.jobject, self), methods.@"radix()I", null);
    }
    pub fn @"useRadix(I)Ljava/util/Scanner;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"useRadix(I)Ljava/util/Scanner;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"setRadix(I)V"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"setRadix(I)V", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"match()Ljava/util/regex/MatchResult;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"match()Ljava/util/regex/MatchResult;", null);
    }
    pub fn @"toString()Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"toString()Ljava/lang/String;", null);
    }
    pub fn @"hasNext()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNext()Z", null);
    }
    pub fn @"next()Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"next()Ljava/lang/String;", null);
    }
    pub fn @"remove()V"(self: *@This(), env: *jui.JNIEnv) !void {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.void, @ptrCast(jui.jobject, self), methods.@"remove()V", null);
    }
    pub fn @"hasNext(Ljava/lang/String;)Z"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNext(Ljava/lang/String;)Z", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"next(Ljava/lang/String;)Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"next(Ljava/lang/String;)Ljava/lang/String;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"hasNext(Ljava/util/regex/Pattern;)Z"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNext(Ljava/util/regex/Pattern;)Z", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"next(Ljava/util/regex/Pattern;)Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"next(Ljava/util/regex/Pattern;)Ljava/lang/String;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"hasNextLine()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNextLine()Z", null);
    }
    pub fn @"nextLine()Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"nextLine()Ljava/lang/String;", null);
    }
    pub fn @"findInLine(Ljava/lang/String;)Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"findInLine(Ljava/lang/String;)Ljava/lang/String;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"findInLine(Ljava/util/regex/Pattern;)Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"findInLine(Ljava/util/regex/Pattern;)Ljava/lang/String;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"findWithinHorizon(Ljava/lang/String;I)Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jint) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"findWithinHorizon(Ljava/lang/String;I)Ljava/lang/String;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)});
    }
    pub fn @"findWithinHorizon(Ljava/util/regex/Pattern;I)Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject, arg1: jui.jint) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"findWithinHorizon(Ljava/util/regex/Pattern;I)Ljava/lang/String;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0), jui.jvalue.toJValue(arg1)});
    }
    pub fn @"skip(Ljava/util/regex/Pattern;)Ljava/util/Scanner;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"skip(Ljava/util/regex/Pattern;)Ljava/util/Scanner;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"skip(Ljava/lang/String;)Ljava/util/Scanner;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"skip(Ljava/lang/String;)Ljava/util/Scanner;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"hasNextBoolean()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNextBoolean()Z", null);
    }
    pub fn @"nextBoolean()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"nextBoolean()Z", null);
    }
    pub fn @"hasNextByte()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNextByte()Z", null);
    }
    pub fn @"hasNextByte(I)Z"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNextByte(I)Z", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"nextByte()B"(self: *@This(), env: *jui.JNIEnv) !jui.jbyte {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.byte, @ptrCast(jui.jobject, self), methods.@"nextByte()B", null);
    }
    pub fn @"nextByte(I)B"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !jui.jbyte {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.byte, @ptrCast(jui.jobject, self), methods.@"nextByte(I)B", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"hasNextShort()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNextShort()Z", null);
    }
    pub fn @"hasNextShort(I)Z"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNextShort(I)Z", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"nextShort()S"(self: *@This(), env: *jui.JNIEnv) !jui.jshort {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.short, @ptrCast(jui.jobject, self), methods.@"nextShort()S", null);
    }
    pub fn @"nextShort(I)S"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !jui.jshort {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.short, @ptrCast(jui.jobject, self), methods.@"nextShort(I)S", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"hasNextInt()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNextInt()Z", null);
    }
    pub fn @"hasNextInt(I)Z"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNextInt(I)Z", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"processIntegerToken(Ljava/lang/String;)Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"processIntegerToken(Ljava/lang/String;)Ljava/lang/String;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"nextInt()I"(self: *@This(), env: *jui.JNIEnv) !jui.jint {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.int, @ptrCast(jui.jobject, self), methods.@"nextInt()I", null);
    }
    pub fn @"nextInt(I)I"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !jui.jint {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.int, @ptrCast(jui.jobject, self), methods.@"nextInt(I)I", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"hasNextLong()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNextLong()Z", null);
    }
    pub fn @"hasNextLong(I)Z"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNextLong(I)Z", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"nextLong()J"(self: *@This(), env: *jui.JNIEnv) !jui.jlong {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.long, @ptrCast(jui.jobject, self), methods.@"nextLong()J", null);
    }
    pub fn @"nextLong(I)J"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !jui.jlong {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.long, @ptrCast(jui.jobject, self), methods.@"nextLong(I)J", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"processFloatToken(Ljava/lang/String;)Ljava/lang/String;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"processFloatToken(Ljava/lang/String;)Ljava/lang/String;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"hasNextFloat()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNextFloat()Z", null);
    }
    pub fn @"nextFloat()F"(self: *@This(), env: *jui.JNIEnv) !jui.jfloat {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.float, @ptrCast(jui.jobject, self), methods.@"nextFloat()F", null);
    }
    pub fn @"hasNextDouble()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNextDouble()Z", null);
    }
    pub fn @"nextDouble()D"(self: *@This(), env: *jui.JNIEnv) !jui.jdouble {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.double, @ptrCast(jui.jobject, self), methods.@"nextDouble()D", null);
    }
    pub fn @"hasNextBigInteger()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNextBigInteger()Z", null);
    }
    pub fn @"hasNextBigInteger(I)Z"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNextBigInteger(I)Z", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"nextBigInteger()Ljava/math/BigInteger;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"nextBigInteger()Ljava/math/BigInteger;", null);
    }
    pub fn @"nextBigInteger(I)Ljava/math/BigInteger;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jint) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"nextBigInteger(I)Ljava/math/BigInteger;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"hasNextBigDecimal()Z"(self: *@This(), env: *jui.JNIEnv) !jui.jboolean {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.boolean, @ptrCast(jui.jobject, self), methods.@"hasNextBigDecimal()Z", null);
    }
    pub fn @"nextBigDecimal()Ljava/math/BigDecimal;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"nextBigDecimal()Ljava/math/BigDecimal;", null);
    }
    pub fn @"reset()Ljava/util/Scanner;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"reset()Ljava/util/Scanner;", null);
    }
    pub fn @"tokens()Ljava/util/stream/Stream;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"tokens()Ljava/util/stream/Stream;", null);
    }
    pub fn @"findAll(Ljava/util/regex/Pattern;)Ljava/util/stream/Stream;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"findAll(Ljava/util/regex/Pattern;)Ljava/util/stream/Stream;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"findAll(Ljava/lang/String;)Ljava/util/stream/Stream;"(self: *@This(), env: *jui.JNIEnv, arg0: jui.jobject) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"findAll(Ljava/lang/String;)Ljava/util/stream/Stream;", &[_]jui.jvalue{jui.jvalue.toJValue(arg0)});
    }
    pub fn @"next()Ljava/lang/Object;"(self: *@This(), env: *jui.JNIEnv) !jui.jobject {
        try load(env);
        _ = class_global orelse return error.ClassNotFound;
        return env.callMethod(.object, @ptrCast(jui.jobject, self), methods.@"next()Ljava/lang/Object;", null);
    }
    pub fn @"<clinit>()V"(env: *jui.JNIEnv) !void {
        try load(env);
        const class = class_global orelse return error.ClassNotFound;
        return env.callStaticMethod(.void, class, methods.@"<clinit>()V", null);
    }

};

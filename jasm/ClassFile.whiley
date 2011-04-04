define ClassFile as {
    int minor_version,
    int major_version,
    {ClassModifier} modifiers,
    class_t type,
    class_t super,
    [class_t] interfaces
}

define ACC_PUBLIC as 0x0001
define ACC_FINAL as  0x0010
define ACC_SUPER as  0x0020
define ACC_INTERFACE as 0x0200
define ACC_ABSTRACT as 0x0400
define ACC_ANNOTATION as 0x2000
define ACC_ENUM as 0x4000

define ClassModifier as {
    ACC_PUBLIC,
    ACC_FINAL,
    ACC_SUPER,
    ACC_INTERFACE,
    ACC_ABSTRACT,
    ACC_ANNOTATION,
    ACC_ENUM
}

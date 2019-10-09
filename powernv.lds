SECTIONS
{
  . = 0;
  _start = .;
  .head : { KEEP(*(.head)) }

  . = 0x500;
}

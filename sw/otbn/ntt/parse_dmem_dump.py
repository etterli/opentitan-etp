import struct
import argparse
from typing import List
from hw.ip.otbn.util.shared.mem_layout import get_memory_layout


# from
# https://github.com/dop-amin/dilithium-on-opentitan-thesis
def parse_dmem_dump(dump: str) -> List[int]:
    '''Parse the output from a dmem dump.

    Expects the dmem dump to be hexadeximal string without leading '0x' in a
    single line.

    Returns a list of size `get_memory_layout().dmem_size_bytes` where each
    element represents one byte of the dmem (at its respective index)
    '''
    # TODO: simplify
    dump = dump.strip("\n")
    dmem_bytes = []
    # 8 32-bit data words + 1 byte integrity info per word = 40 bytes
    bytes_w_integrity = 8 * 4 + 8
    for w in struct.iter_unpack(f"<{bytes_w_integrity}s", bytes.fromhex(dump)):
        tmp = []
        # discard byte indicating integrity status
        for v in struct.iter_unpack("<BI", w[0]):
            tmp += [x for x in struct.unpack("4B", v[1].to_bytes(4, "big"))]
        dmem_bytes += tmp
    assert len(dmem_bytes) == get_memory_layout().dmem_size_bytes
    return dmem_bytes


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('dmem_dump',
                        metavar='dmem_dump',
                        type=argparse.FileType('rb'),
                        help=('DMEM dump file containing the binary DMEM blob.'))
    parser.add_argument('-o',
                        '--output',
                        metavar='output',
                        type=argparse.FileType('w'),
                        help=('File to write the parsed DMEM dump.'))
    args = parser.parse_args()

    hexdata = args.dmem_dump.read().hex()

    bytes = parse_dmem_dump(hexdata)

    # output it in the same way as
    #  hw/ip/otbn/util/otbn_objdump.py -s -j .data <program>.elf
    output = "DMEM dump. First column is offset. The other four are the data in 32b little endian chunks.\n"
    for offset in range(0, len(bytes) // 4, 16):
        line = f"{offset:04x}"
        for word in range(4):
            index = offset + word * 4
            # line += (f" {bytes[index+0]:02x}{bytes[index+1]:02x}{bytes[index+2]:02x}{bytes[index+3]:02x}")
            # little endian
            line += (f" {bytes[index+3]:02x}{bytes[index+2]:02x}{bytes[index+1]:02x}{bytes[index+0]:02x}")
        output += line + "\n"

    print(output)

    if args.output:
        args.output.write(output)


if (__name__ == "__main__"):
    main()

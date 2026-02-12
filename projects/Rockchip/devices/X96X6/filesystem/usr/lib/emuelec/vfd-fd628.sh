#!/bin/sh
# FD628 VFD Library for X96X6
# Vertical (segment-based) mapping with icon state tracking
#
# Hardware: FD628, 4x7-segment digits + 7 icons
# Protocol: SPI 3-wire (CLK/DATA/STB), LSB first
#
# Memory layout (14 bytes starting at address 0xC0):
#   byte0=seg_A, byte1=0, byte2=seg_B, byte3=0, ...
#   byte12=seg_G, byte13=0
#
# Segment byte format:
#   bit7=digit1, bit6=digit2, bit5=digit3, bit4=digit4
#   bit3=icon (0x08)
#   bits 2-0: unused
#
# Icon-to-segment mapping (confirmed by hardware test):
#   apps  -> seg_A (byte0)  -> bit3 of byte0
#   setup -> seg_B (byte2)  -> bit3 of byte2
#   usb   -> seg_C (byte4)  -> bit3 of byte4
#   card  -> seg_D (byte6)  -> bit3 of byte6
#   colon -> seg_E (byte8)  -> bit3 of byte8
#   wifi  -> seg_F (byte10) -> bit3 of byte10
#   data  -> seg_G (byte12) -> bit3 of byte12

VFD_DATA=148
VFD_CLK=149
VFD_STB=150

# Icon state (global, preserved across display updates)
ICON_APPS=0
ICON_SETUP=0
ICON_USB=0
ICON_CARD=0
ICON_COLON=0
ICON_WIFI=0
ICON_DATA=0

# Last displayed segment values (raw, without icon bits)
# Used by vfd_icon() to refresh display immediately
LAST_SEG_A=0 LAST_SEG_B=0 LAST_SEG_C=0 LAST_SEG_D=0
LAST_SEG_E=0 LAST_SEG_F=0 LAST_SEG_G=0

# 7-segment font table (decimal values)
# Bit mapping: bit0=a, bit1=b, bit2=c, bit3=d, bit4=e, bit5=f, bit6=g
#   aaa
#  f   b
#   ggg
#  e   c
#   ddd
FONT_0=63     # 0b0111111 = abcdef
FONT_1=6      # 0b0000110 = bc
FONT_2=91     # 0b1011011 = abdeg
FONT_3=79     # 0b1001111 = abcdg
FONT_4=102    # 0b1100110 = bcfg
FONT_5=109    # 0b1101101 = acdfg
FONT_6=125    # 0b1111101 = acdefg
FONT_7=7      # 0b0000111 = abc
FONT_8=127    # 0b1111111 = abcdefg
FONT_9=111    # 0b1101111 = abcdfg
FONT_A=119    # 0b1110111 = abcefg
FONT_b=124    # 0b1111100 = cdefg (lowercase, uppercase indistinguishable)
FONT_C=57     # 0b0111001 = adef (uppercase)
FONT_c=88     # 0b1011000 = deg (lowercase)
FONT_d=94     # 0b1011110 = bcdeg
FONT_E=121    # 0b1111001 = adefg
FONT_F=113    # 0b1110001 = aefg
FONT_G=61     # 0b0111101 = acdef
FONT_H=118    # 0b1110110 = bcefg
FONT_I=6      # 0b0110000 = bc (same as 1)
FONT_i=16     # 0b0001000 = c (lowercase i, different from uppercase I)
FONT_L=56     # 0b0111000 = def (uppercase)
FONT_l=48     # 0b0110000 = ef (lowercase, thin)
FONT_n=84     # 0b1010100 = ceg (lowercase n)
FONT_O=63     # 0b0111111 = abcdef (uppercase, full circle)
FONT_o=92     # 0b1011100 = cdeg (lowercase)
FONT_P=115    # 0b1110011 = abefg
FONT_S=109    # 0b1101101 = acdfg (same as 5)
FONT_t=120    # 0b1111000 = defg
FONT_U=62     # 0b0111110 = bcdef (uppercase)
FONT_u=28     # 0b0011100 = cde (lowercase)
FONT_Y=110    # 0b1101110 = bcdfg
FONT_DASH=64  # 0b1000000 = g
FONT_BLANK=0  # 0b0000000 = (empty)

vfd_init() {
    local p
    for p in $VFD_DATA $VFD_CLK $VFD_STB; do
        [ -d "/sys/class/gpio/gpio${p}" ] || echo "$p" > /sys/class/gpio/export 2>/dev/null
        echo out > "/sys/class/gpio/gpio${p}/direction" 2>/dev/null
    done
    echo 1 > "/sys/class/gpio/gpio${VFD_STB}/value"
    echo 1 > "/sys/class/gpio/gpio${VFD_CLK}/value"
}

vfd_send_byte() {
    local val=$1 bit=0
    while [ $bit -lt 8 ]; do
        echo 0 > "/sys/class/gpio/gpio${VFD_CLK}/value"
        echo $(( (val >> bit) & 1 )) > "/sys/class/gpio/gpio${VFD_DATA}/value"
        echo 1 > "/sys/class/gpio/gpio${VFD_CLK}/value"
        bit=$((bit + 1))
    done
}

vfd_cmd() {
    echo 0 > "/sys/class/gpio/gpio${VFD_STB}/value"
    local byte
    for byte in "$@"; do
        vfd_send_byte "$byte"
    done
    echo 1 > "/sys/class/gpio/gpio${VFD_STB}/value"
}

# Send display data with icon state automatically applied
# Args: seg_a seg_b seg_c seg_d seg_e seg_f seg_g
vfd_display_segments() {
    local sa=$1 sb=$2 sc=$3 sd=$4 se=$5 sf=$6 sg=$7

    # Save raw segment values (before icons) for vfd_icon() refresh
    LAST_SEG_A=$sa LAST_SEG_B=$sb LAST_SEG_C=$sc LAST_SEG_D=$sd
    LAST_SEG_E=$se LAST_SEG_F=$sf LAST_SEG_G=$sg

    # Apply icon bits (bit3 = 0x08 = 8) to each segment
    [ "$ICON_APPS"  = 1 ] && sa=$((sa | 8))
    [ "$ICON_SETUP" = 1 ] && sb=$((sb | 8))
    [ "$ICON_USB"   = 1 ] && sc=$((sc | 8))
    [ "$ICON_CARD"  = 1 ] && sd=$((sd | 8))
    [ "$ICON_COLON" = 1 ] && se=$((se | 8))
    [ "$ICON_WIFI"  = 1 ] && sf=$((sf | 8))
    [ "$ICON_DATA"  = 1 ] && sg=$((sg | 8))

    vfd_cmd 3
    vfd_cmd 64
    vfd_cmd 192 $sa 0 $sb 0 $sc 0 $sd 0 $se 0 $sf 0 $sg 0
    vfd_cmd 143
}

# Get font code for a character
_font_code() {
    case "$1" in
        0) echo $FONT_0 ;; 1) echo $FONT_1 ;; 2) echo $FONT_2 ;;
        3) echo $FONT_3 ;; 4) echo $FONT_4 ;; 5) echo $FONT_5 ;;
        6) echo $FONT_6 ;; 7) echo $FONT_7 ;; 8) echo $FONT_8 ;;
        9) echo $FONT_9 ;;
        A) echo $FONT_A ;; a) echo $FONT_A ;;
        B) echo $FONT_b ;; b) echo $FONT_b ;;
        C) echo $FONT_C ;; c) echo $FONT_c ;;
        D) echo $FONT_d ;; d) echo $FONT_d ;;
        E) echo $FONT_E ;; e) echo $FONT_E ;;
        F) echo $FONT_F ;; f) echo $FONT_F ;;
        G) echo $FONT_G ;; g) echo $FONT_G ;;
        H) echo $FONT_H ;; h) echo $FONT_H ;;
        I) echo $FONT_I ;; i) echo $FONT_i ;;
        L) echo $FONT_L ;; l) echo $FONT_l ;;
        N) echo $FONT_n ;; n) echo $FONT_n ;;
        O) echo $FONT_O ;; o) echo $FONT_o ;;
        P) echo $FONT_P ;; p) echo $FONT_P ;;
        S) echo $FONT_S ;; s) echo $FONT_S ;;
        T) echo $FONT_t ;; t) echo $FONT_t ;;
        U) echo $FONT_U ;; u) echo $FONT_u ;;
        Y) echo $FONT_Y ;; y) echo $FONT_Y ;;
        -) echo $FONT_DASH ;;
        *) echo $FONT_BLANK ;;
    esac
}

# Display 4-character text (preserves current icon state)
vfd_text() {
    local text="$1"
    while [ ${#text} -lt 4 ]; do text="${text} "; done

    local seg_a=0 seg_b=0 seg_c=0 seg_d=0 seg_e=0 seg_f=0 seg_g=0
    local i=0
    while [ $i -lt 4 ]; do
        local ch=$(echo "$text" | cut -c$((i + 1)))
        local code=$(_font_code "$ch")
        local pos_mask=$((1 << (7 - i)))

        [ $((code & 1))  -ne 0 ] && seg_a=$((seg_a | pos_mask))
        [ $((code & 2))  -ne 0 ] && seg_b=$((seg_b | pos_mask))
        [ $((code & 4))  -ne 0 ] && seg_c=$((seg_c | pos_mask))
        [ $((code & 8))  -ne 0 ] && seg_d=$((seg_d | pos_mask))
        [ $((code & 16)) -ne 0 ] && seg_e=$((seg_e | pos_mask))
        [ $((code & 32)) -ne 0 ] && seg_f=$((seg_f | pos_mask))
        [ $((code & 64)) -ne 0 ] && seg_g=$((seg_g | pos_mask))

        i=$((i + 1))
    done

    vfd_display_segments $seg_a $seg_b $seg_c $seg_d $seg_e $seg_f $seg_g
}

# Display time HH:MM with colon icon
# Usage: vfd_clock [HH MM] — without args uses current system time
vfd_clock() {
    local hh mm
    if [ -n "$1" ]; then
        hh="$1"; mm="$2"
    else
        hh=$(date +%H)
        mm=$(date +%M)
    fi

    # Extract individual digits via cut (avoids octal issues with leading zeros)
    local h1=$(echo "$hh" | cut -c1)
    local h2=$(echo "$hh" | cut -c2)
    local m1=$(echo "$mm" | cut -c1)
    local m2=$(echo "$mm" | cut -c2)

    local seg_a=0 seg_b=0 seg_c=0 seg_d=0 seg_e=0 seg_f=0 seg_g=0
    local pos=0 code pos_mask
    for ch in $h1 $h2 $m1 $m2; do
        code=$(_font_code "$ch")
        pos_mask=$((1 << (7 - pos)))

        [ $((code & 1))  -ne 0 ] && seg_a=$((seg_a | pos_mask))
        [ $((code & 2))  -ne 0 ] && seg_b=$((seg_b | pos_mask))
        [ $((code & 4))  -ne 0 ] && seg_c=$((seg_c | pos_mask))
        [ $((code & 8))  -ne 0 ] && seg_d=$((seg_d | pos_mask))
        [ $((code & 16)) -ne 0 ] && seg_e=$((seg_e | pos_mask))
        [ $((code & 32)) -ne 0 ] && seg_f=$((seg_f | pos_mask))
        [ $((code & 64)) -ne 0 ] && seg_g=$((seg_g | pos_mask))

        pos=$((pos + 1))
    done

    # Always show colon when displaying clock
    ICON_COLON=1
    vfd_display_segments $seg_a $seg_b $seg_c $seg_d $seg_e $seg_f $seg_g
}

# Set or clear an icon (immediately refreshes display)
# Usage: vfd_icon <name> <on|off>
vfd_icon() {
    local val=0
    [ "$2" = "on" ] && val=1
    case "$1" in
        apps|app)   ICON_APPS=$val ;;
        setup)      ICON_SETUP=$val ;;
        usb)        ICON_USB=$val ;;
        card)       ICON_CARD=$val ;;
        colon)      ICON_COLON=$val ;;
        wifi)       ICON_WIFI=$val ;;
        data)       ICON_DATA=$val ;;
    esac
    # Refresh display with last known digit data + updated icon state
    vfd_display_segments $LAST_SEG_A $LAST_SEG_B $LAST_SEG_C $LAST_SEG_D \
                         $LAST_SEG_E $LAST_SEG_F $LAST_SEG_G
}

# Clear display and reset all icon states
vfd_clear() {
    ICON_APPS=0; ICON_SETUP=0; ICON_USB=0; ICON_CARD=0
    ICON_COLON=0; ICON_WIFI=0; ICON_DATA=0
    vfd_cmd 3
    vfd_cmd 64
    vfd_cmd 192 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    vfd_cmd 143
}

# Set display brightness (0-7)
vfd_brightness() {
    local level=${1:-7}
    vfd_cmd $((136 + level))
}

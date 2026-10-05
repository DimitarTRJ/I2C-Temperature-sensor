import serial
import time

PORT = "COM5"
BAUD = 9600

ser = serial.Serial(PORT, BAUD, timeout=1)

print(f"Connected to {PORT} @ {BAUD} baud")
print("Waiting for data...\n")

try:
    while True:
        if ser.in_waiting:
            data = ser.read(ser.in_waiting)
            print(data.decode(errors="ignore"), end="")
        time.sleep(0.01)
except KeyboardInterrupt:
    print("\nClosing connection.")
finally:
    ser.close()


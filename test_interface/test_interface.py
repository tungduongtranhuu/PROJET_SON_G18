import serial
import tkinter as tk

class Interface(tk.Tk):
    def __init__(self):
        super().__init__()
        self.geometry(f"{800}x{500}")
        self.title("Effect pedal")   

        self.v1 = tk.DoubleVar()
        self.s1 = tk.Scale(self, from_ = 0, to = 1, resolution = 0.01, length = 350, orient = tk.HORIZONTAL, command=self.set_led)
        self.s1.pack(anchor = tk.CENTER)

        self.quitt = tk.Button(self, text="Quit")
        self.quitt.pack(side = tk.BOTTOM, fill='x')
        self.quitt.bind('<Button-1>',self.close)

        self.ser = serial.Serial("COM3", 115200)

    def set_led(self, value):
        if self.ser.is_open:
            self.ser.write(f"LED={value}\n".encode())

    def close(self,event):
        self.destroy()

fen = Interface()
fen.mainloop()
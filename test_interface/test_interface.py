import serial
import tkinter as tk

class Interface(tk.Tk):
    def __init__(self):
        super().__init__()
        self.geometry(f"{700}x{500}")
        self.title("Effect pedal")   

        self.t0 = tk.Label(self, text = "General", font="Serif 10 bold", pady = 20)
        self.t0.pack(side = tk.TOP)

        self.row0 = tk.Frame(self)
        self.row0.pack(fill="x", padx=[20, 30])

        self.st0 = tk.Label(self.row0, text = "Volume", font="Serif 10 bold", pady = 15)
        self.st0.pack(side = tk.LEFT)

        self.v0 = tk.DoubleVar()
        self.s0 = tk.Scale(self.row0, from_ = 0, to = 1, resolution = 0.01, length = 400, orient = tk.HORIZONTAL, variable = self.v0, command=self.send_values)
        self.s0.pack(anchor = tk.CENTER)

        self.t1 = tk.Label(self, text = "Echo", font="Serif 10 bold", pady = 20)
        self.t1.pack(side = tk.TOP)

        self.row11 = tk.Frame(self)
        self.row11.pack(fill="x", padx=[20, 30])

        self.st11 = tk.Label(self.row11, text = "Duration", font="Serif 10 bold", pady = 15)
        self.st11.pack(side = tk.LEFT)

        self.v11 = tk.DoubleVar()
        self.s11 = tk.Scale(self.row11, from_ = 0, to = 1, resolution = 0.01, length = 400, orient = tk.HORIZONTAL, variable = self.v11, command=self.send_values)
        self.s11.pack(anchor = tk.CENTER)

        self.row12 = tk.Frame(self)
        self.row12.pack(fill="x", padx=[20, 110])

        self.st12 = tk.Label(self.row12, text = "Feedback coefficient", font="Serif 10 bold", pady = 15)
        self.st12.pack(side = tk.LEFT)

        self.v12 = tk.DoubleVar()
        self.s12 = tk.Scale(self.row12, from_ = 0, to = 1, resolution = 0.01, length = 400, orient = tk.HORIZONTAL, variable = self.v12, command=self.send_values)
        self.s12.pack(anchor = tk.CENTER)

        self.t2 = tk.Label(self, text = "Distorsion", font="Serif 10 bold", pady = 20)
        self.t2.pack(side = tk.TOP)

        self.row21 = tk.Frame(self)
        self.row21.pack(fill="x", padx=[20, 15])

        self.st21 = tk.Label(self.row21, text = "Drive", font="Serif 10 bold", pady = 15)
        self.st21.pack(side = tk.LEFT)

        self.v21 = tk.DoubleVar()
        self.s21 = tk.Scale(self.row21, from_ = 0, to = 1, resolution = 0.01, length = 400, orient = tk.HORIZONTAL, variable = self.v21, command=self.send_values)
        self.s21.pack(anchor = tk.CENTER)

        self.row22 = tk.Frame(self)
        self.row22.pack(fill="x", padx=[20, 15])

        self.st22 = tk.Label(self.row22, text = "Tone", font="Serif 10 bold", pady = 15)
        self.st22.pack(side = tk.LEFT)

        self.v22 = tk.DoubleVar()
        self.s22 = tk.Scale(self.row22, from_ = 0, to = 1, resolution = 0.01, length = 400, orient = tk.HORIZONTAL, variable = self.v22, command=self.send_values)
        self.s22.pack(anchor = tk.CENTER)

        self.quitt = tk.Button(self, text="Quit")
        self.quitt.pack(side = tk.BOTTOM, fill='x')
        self.quitt.bind('<Button-1>',self.close)

        self.ser = serial.Serial("COM3", 9600)

    def send_values(self, value):
        volume = self.v0.get()
        duration = self.v11.get()
        feedback = self.v12.get()
        drive = self.v21.get()
        tone = self.v22.get()

        message = f"{volume},{duration},{feedback},{drive},{tone}\n"

        if self.ser.is_open:
            self.ser.write(message.encode())

    def close(self,event):
        self.destroy()

fen = Interface()
fen.mainloop()
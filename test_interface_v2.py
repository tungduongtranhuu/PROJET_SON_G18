
import serial
import tkinter as tk
from tkinter import ttk
from tkinter import Canvas

class Interface(tk.Tk):
    def __init__(self):
        super().__init__()
        self.geometry(f"{800}x{650}")
        self.title("Effect pedal")   

        self.t0 = ttk.Label(self, text = "General", font="Serif 10 bold", padding = 20)
        self.t0.pack(side = tk.TOP)

        self.row0 = ttk.Frame(self)
        self.row0.pack(fill="x", padx=[20, 50])

        self.st0 = ttk.Label(self.row0, text = "Volume", font="Serif 10 bold", padding = 15)
        self.st0.pack(side = tk.LEFT)

        self.v0 = tk.DoubleVar()
        self.s0 = ttk.Scale(self.row0, from_ = 0, to = 1, length = 525, orient = tk.HORIZONTAL, variable = self.v0)
        self.s0.bind("<ButtonRelease-1>", self.send_values)
        self.s0.pack(side = tk.RIGHT)

        self.val0 = ttk.Label(self.row0, text = "0.00", font="Serif 10 bold", padding = 15)
        self.val0.pack(side = tk.RIGHT)

        self.t1 = ttk.Label(self, text = "Echo", font="Serif 10 bold", padding = 20)
        self.t1.pack(side = tk.TOP)

        self.row11 = ttk.Frame(self)
        self.row11.pack(fill="x", padx=[20, 50])

        self.st11 = ttk.Label(self.row11, text = "Duration", font="Serif 10 bold", padding = 15)
        self.st11.pack(side = tk.LEFT)

        self.v11 = tk.DoubleVar()
        self.s11 = ttk.Scale(self.row11, from_ = 0, to = 0.25, length = 525, orient = tk.HORIZONTAL, variable = self.v11)
        self.s11.bind("<ButtonRelease-1>", self.send_values)
        self.s11.pack(side = tk.RIGHT)

        self.val11 = ttk.Label(self.row11, text = "0.00", font="Serif 10 bold", padding = 15)
        self.val11.pack(side = tk.RIGHT)

        self.row12 = ttk.Frame(self)
        self.row12.pack(fill="x", padx=[20, 50])

        self.st12 = ttk.Label(self.row12, text = "Feedback coeff", font="Serif 10 bold", padding = 15)
        self.st12.pack(side = tk.LEFT)

        self.v12 = tk.DoubleVar()
        self.s12 = ttk.Scale(self.row12, from_ = 0, to = 0.95, length = 525, orient = tk.HORIZONTAL, variable = self.v12)
        self.s12.bind("<ButtonRelease-1>", self.send_values)
        self.s12.pack(side = tk.RIGHT)

        self.val12 = ttk.Label(self.row12, text = "0.00", font="Serif 10 bold", padding = 15)
        self.val12.pack(side = tk.RIGHT)

        self.t2 = ttk.Label(self, text = "Distorsion", font="Serif 10 bold", padding = 20)
        self.t2.pack(side = tk.TOP)

        self.row21 = ttk.Frame(self)
        self.row21.pack(fill="x", padx=[20, 50])

        self.st21 = ttk.Label(self.row21, text = "Drive", font="Serif 10 bold", padding = 15)
        self.st21.pack(side = tk.LEFT)

        self.v21 = tk.DoubleVar()
        self.s21 = ttk.Scale(self.row21, from_ = 1, to = 50, length = 525, orient = tk.HORIZONTAL, variable = self.v21)
        self.s21.bind("<ButtonRelease-1>", self.send_values)
        self.s21.pack(side = tk.RIGHT)

        self.val21 = ttk.Label(self.row21, text = "1.0", font="Serif 10 bold", padding = 15)
        self.val21.pack(side = tk.RIGHT)

        self.row22 = ttk.Frame(self)
        self.row22.pack(fill="x", padx=[20, 50])

        self.st22 = ttk.Label(self.row22, text = "Tone", font="Serif 10 bold", padding = 15)
        self.st22.pack(side = tk.LEFT)

        self.v22 = tk.DoubleVar()
        self.s22 = ttk.Scale(self.row22, from_ = 1500, to = 8000, length = 525, orient = tk.HORIZONTAL, variable = self.v22)
        self.s22.bind("<ButtonRelease-1>", self.send_values)
        self.s22.pack(side = tk.RIGHT)

        self.val22 = ttk.Label(self.row22, text = "1500", font="Serif 10 bold", padding = 15)
        self.val22.pack(side = tk.RIGHT)

        self.t3 = ttk.Label(self, text = "Chorus", font="Serif 10 bold", padding = 20)
        self.t3.pack(side = tk.TOP)

        self.row31 = ttk.Frame(self)
        self.row31.pack(fill="x", padx=[20, 50])

        self.st31 = ttk.Label(self.row31, text = "Rate", font="Serif 10 bold", padding = 15)
        self.st31.pack(side = tk.LEFT)

        self.v31 = tk.DoubleVar()
        self.s31 = ttk.Scale(self.row31, from_ = 0.05, to = 5, length = 525, orient = tk.HORIZONTAL, variable = self.v31)
        self.s31.bind("<ButtonRelease-1>", self.send_values)
        self.s31.pack(side = tk.RIGHT)

        self.val31 = ttk.Label(self.row31, text = "0.05", font="Serif 10 bold", padding = 15)
        self.val31.pack(side = tk.RIGHT)

        self.row32 = ttk.Frame(self)
        self.row32.pack(fill="x", padx=[20, 50])

        self.st32 = ttk.Label(self.row32, text = "Depth", font="Serif 10 bold", padding = 15)
        self.st32.pack(side = tk.LEFT)

        self.v32 = tk.DoubleVar()
        self.s32 = ttk.Scale(self.row32, from_ = 0.5, to = 10, length = 525, orient = tk.HORIZONTAL, variable = self.v32)
        self.s32.bind("<ButtonRelease-1>", self.send_values)
        self.s32.pack(side = tk.RIGHT)

        self.val32 = ttk.Label(self.row32, text = "0.5", font="Serif 10 bold", padding = 15)
        self.val32.pack(side = tk.RIGHT)

        self.quitt = ttk.Button(self, text="Quit")
        self.quitt.pack(side = tk.BOTTOM, fill='x')
        self.quitt.bind('<Button-1>',self.close)

        self.ser = serial.Serial("COM3", 9600)

    def send_values(self, value):
        self.val0.config(text=f"{float(self.v0.get()):.2f}")
        self.val11.config(text=f"{float(self.v11.get()):.2f}")
        self.val12.config(text=f"{float(self.v12.get()):.2f}")
        self.val21.config(text=f"{float(self.v21.get()):.1f}")
        self.val22.config(text=f"{float(self.v22.get()):.0f}")
        self.val31.config(text=f"{float(self.v31.get()):.2f}")
        self.val32.config(text=f"{float(self.v32.get()):.1f}")

        volume = self.v0.get()
        duration = self.v11.get()
        feedback = self.v12.get()
        drive = self.v21.get()
        tone = self.v22.get()
        rate = self.v31.get()
        depth = self.v32.get()

        message = f"{volume},{duration},{feedback},{drive},{tone},{rate},{depth}\n"

        if self.ser.is_open:
            self.ser.write(message.encode())


    def close(self,event):
        self.destroy()

fen = Interface()
fen.mainloop()
from tkinter import *

master = Tk()
master.title('Trajectory Generator')
master.geometry("500x300")

user_input_start_pos = StringVar(master)
user_input_end_pos = StringVar(master)
user_input_max_vel = StringVar(master)
user_input_max_acc = StringVar(master)
user_input_delta = StringVar(master)
    
def get_input_values():
    startPos = float(user_input_start_pos.get())
    endPos = float(user_input_end_pos.get())
    maxVel = float(user_input_max_vel.get())
    maxAcc = float(user_input_max_acc.get())
    delta = float(user_input_delta.get())
    entryEndPos.delete(0, END)
    entryEndPos.insert(0, startPos)

Label(master, text="Set Start Position").place(x=0, y=0)
Label(master, text="Set End Position").place(x=0, y=30)
Label(master, text="Set Max. Velocity").place(x=0, y=60)
Label(master, text="Set Max. Acceleration").place(x=0, y=90)
Label(master, text="Set Time Delta").place(x=0, y=120)

entryStartPos = Entry(master, textvariable=user_input_start_pos)
entryStartPos.place(x=200, y=0)
entryEndPos = Entry(master, textvariable=user_input_end_pos)
entryEndPos.place(x=200, y=30)
entryMaxVel = Entry(master, textvariable=user_input_max_vel)
entryMaxVel.place(x=200, y=60)
entryMaxAcc = Entry(master, textvariable=user_input_max_acc)
entryMaxAcc.place(x=200, y=90)
entryDelta = Entry(master, textvariable=user_input_delta)
entryDelta.place(x=200, y=120)

startComputation = Button(master, text='Start Computation', command=get_input_values)
startComputation.place(x=0, y=200)

mainloop()
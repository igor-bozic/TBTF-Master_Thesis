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

Label(master, text="Set Start Position").grid(row=0, ipadx=0)
Label(master, text="Set End Position").grid(row=1)
Label(master, text="Set Max. Velocity").grid(row=2)
Label(master, text="Set Max. Acceleration").grid(row=3)
Label(master, text="Set Time Delta").grid(row=4)

entryStartPos = Entry(master, textvariable=user_input_start_pos)
entryStartPos.grid(row=0, column=1)
entryEndPos = Entry(master, textvariable=user_input_end_pos)
entryEndPos.grid(row=1, column=1)
entryMaxVel = Entry(master, textvariable=user_input_max_vel)
entryMaxVel.grid(row=2, column=1)
entryMaxAcc = Entry(master, textvariable=user_input_max_acc)
entryMaxAcc.grid(row=3, column=1)
entryDelta = Entry(master, textvariable=user_input_delta)
entryDelta.grid(row=4, column=1)

startComputation = Button(master, text='Start Computation',command=get_input_values)
startComputation.grid(row=5, column=0)

mainloop()
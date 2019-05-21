from tkinter import *
fields = ('First Number', 'Second Number', 'Result')

def addition(entries):
   first_nr = (float(entries['First Number'].get()))
   second_nr = (float(entries['Second Number'].get()))
   res = first_nr + second_nr
   entries['Result'].delete(0,END)
   entries['Result'].insert(0, res)
   
def subtraction(entries):
   first_nr = (float(entries['First Number'].get()))
   second_nr = (float(entries['Second Number'].get())) 
   res = first_nr - second_nr
   entries['Result'].delete(0,END)
   entries['Result'].insert(0, res)
   
def multiplication(entries):
   first_nr = (float(entries['First Number'].get()))
   second_nr = (float(entries['Second Number'].get())) 
   res = first_nr * second_nr
   entries['Result'].delete(0,END)
   entries['Result'].insert(0, res)
   
def division(entries):
   first_nr = (float(entries['First Number'].get()))
   second_nr = (float(entries['Second Number'].get())) 
   res = first_nr / second_nr
   entries['Result'].delete(0,END)
   entries['Result'].insert(0, res)

def makeform(root, fields):
   entries = {}
   for field in fields:
      row = Frame(root)
      lab = Label(row, width=22, text=field+": ", anchor='w')
      ent = Entry(row)
      ent.insert(0,"0")
      row.pack(side=TOP, fill=X, padx=5, pady=5)
      lab.pack(side=LEFT)
      ent.pack(side=RIGHT, expand=YES, fill=X)
      entries[field] = ent
   return entries

if __name__ == '__main__':
   root = Tk()
   ents = makeform(root, fields)
   root.bind('<Return>', (lambda event, e=ents: fetch(e)))   
   b1 = Button(root, text='Addition',
          command=(lambda e=ents: addition(e)))
   b1.pack(side=LEFT, padx=5, pady=5)
   b2 = Button(root, text='Subtraction',
          command=(lambda e=ents: subtraction(e)))
   b2.pack(side=LEFT, padx=5, pady=5)
   b3 = Button(root, text='Multiplication',
          command=(lambda e=ents: multiplication(e)))
   b3.pack(side=LEFT, padx=5, pady=5)
   b4 = Button(root, text='Division',
          command=(lambda e=ents: division(e)))
   b4.pack(side=LEFT, padx=5, pady=5)
   bx = Button(root, text='Quit', command=root.quit)
   bx.pack(side=LEFT, padx=5, pady=5)
   root.mainloop()
""" 
Function traj_1D

Takes as input the start position, end position, maximum velocity,
maximum acceleration and time steps (delta).
The output is time, position velocity and acceleration for each time step (delta).
"""

from math import sqrt
import numpy as np

def traj_1D(start_pos, end_pos, max_vel, max_acc, dt):

    t_0 = 0
    t_1 = 0
    t_2 = 0
    t_3 = 0

    sign = 1
    if start_pos > end_pos:
        sign = -1
    
    if max_vel >= sqrt(max_acc * abs(end_pos - start_pos)):
        t_1 = t_0 + sqrt((abs(end_pos - start_pos)) / max_acc)
        t_2 = t_1
        t_3 = t_2 + (t_1 - t_0)
    
    if max_vel < sqrt(max_acc * abs(end_pos - start_pos)):
        t_1 = t_0 + (max_vel / max_acc)
        t_2 = t_1 + (abs(end_pos - start_pos) - 2 * (0.5 * max_acc * pow(t_1 - t_0, 2))) / max_vel
        t_3 = t_2 + (t_1 - t_0)
        
    d = np.arange(t_0, t_3+dt, dt)
    len_of_d = len(d)
    
    acc = []
    vel = []
    pos = []
    
    i = t_0
    for i in range(len_of_d):
        if d[i] >= t_0 and d[i] < t_1:
            acc.append(max_acc)
            vel.append(max_acc * (d[i] - t_0))
            pos.append(start_pos + sign * (0.5 * max_acc * pow(d[i] - t_0, 2)))
            
        if d[i] >= t_1 and d[i] < t_2 and t_2 > t_1:
            acc.append(0)
            vel.append(max_acc * (t_1 - t_0))
            pos.append(start_pos + sign * max_acc * (t_1 - t_0) * (d[i] - 0.5 * (t_1 - t_0)))
            
        if d[i] >= t_2 and d[i] <= t_3:
            acc.append(-max_acc)
            vel.append(max_acc * (t_1 - t_0) - max_acc * (d[i] - t_2))
            pos.append(start_pos + sign * max_acc * (t_1 - t_0) * (t_2 - 0.5 * (t_1 + t_0) + (d[i] - t_2) * (1 - 0.5 * (d[i] - t_2) / (t_3 - t_2))))
    
    if len_of_d != len(acc):
        acc.append(0)
        vel.append(0)
        pos.append(end_pos)
    
    return acc, vel, pos, d    
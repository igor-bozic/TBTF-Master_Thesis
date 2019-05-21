"""
Function traj_3D

Takes a vector [x y z] as input which for the start and end position.
Also the maximum velocity, maximum acceleration and time steps (delta).
The output is time, velocity, acceleration and position in a 3 dimensional space.
"""

from math import sqrt
import numpy as np
import trajectory_1d

def traj_3D(start_pos, end_pos, max_vel, max_acc, dt):
    start_pos = np.array(start_pos)
    end_pos = np.array(end_pos)
    pos_vec_time = []
    vel_vec_time = []
    acc_vec_time = []
    
    
    if start_pos[0] == end_pos[0] and start_pos[1] == end_pos[1] and start_pos[2] == end_pos[2]:
        velocity = 0
        acceleration = 0
        position = start_pos
        
    else:
        e = [0,0,0]
        delta = dt
        
        distance_vec = end_pos - start_pos
        distance = sqrt(pow(distance_vec[0], 2) + pow(distance_vec[1], 2) + pow(distance_vec[2], 2))
        e[0] = distance_vec[0] / distance
        e[1] = distance_vec[1] / distance
        e[2] = distance_vec[2] / distance
        e = np.array(e)       
        
        acc, vel, pos, d = trajectory_1d.traj_1D(0, distance, max_vel, max_acc, delta)
        
        for i in range(len(pos)):
            pos_vec_time.append(pos[i] * e + start_pos)
            vel_vec_time.append(vel[i] * e)
            acc_vec_time.append(acc[i] * e)
            
    position = pos_vec_time
    velocity = vel_vec_time
    acceleration = acc_vec_time
    
    return acceleration, velocity, position
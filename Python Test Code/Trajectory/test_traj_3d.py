import trajectory_3d
import numpy as np

from mpl_toolkits.mplot3d import Axes3D
import matplotlib 
matplotlib.use('PDF')
import matplotlib.pyplot as pyplot

acc_3d, vel_3d, pos_3d = trajectory_3d.traj_3D([1,10,0], [10,10,10], 2, 1, 0.1)

acc_3d = np.array(acc_3d)
acc_3d_x = acc_3d[:,0]
acc_3d_y = acc_3d[:,1]
acc_3d_z = acc_3d[:,2]

vel_3d = np.array(vel_3d)
vel_3d_x = vel_3d[:,0]
vel_3d_y = vel_3d[:,1]
vel_3d_z = vel_3d[:,2]

pos_3d = np.array(pos_3d)
pos_3d_x = pos_3d[:,0]
pos_3d_y = pos_3d[:,1]
pos_3d_z = pos_3d[:,2]

fig = pyplot.figure()
ax = fig.add_subplot(111, projection='3d')
ax.plot(pos_3d_x, pos_3d_y, pos_3d_z, c='r')
ax = fig.add_subplot(211, projection='3d')
ax.plot(acc_3d_x, acc_3d_y, acc_3d_z, c='r')
ax = fig.add_subplot(311, projection='3d')
ax.plot(vel_3d_x, vel_3d_y, vel_3d_z, c='r')
pyplot.savefig('trajectory_3d_plot.pdf')
pyplot.show()
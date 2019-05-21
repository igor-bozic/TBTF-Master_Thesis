import trajectory_1d

import matplotlib 
matplotlib.use('PDF')
import matplotlib.pyplot as pyplot

acc_1d, vel_1d, pos_1d, d = trajectory_1d.traj_1D(0, 10, 2, 1, 0.1)

pyplot.plot(d, acc_1d, label='Acceleration', linestyle='dotted')
pyplot.plot(d, vel_1d, label='Velocity', linestyle='dashed')
pyplot.plot(d, pos_1d, label='Position', linestyle='solid')
pyplot.legend(loc='upper left')
pyplot.title("Trajectory 1-D Plot")
pyplot.savefig('trajectory_1d_plot.pdf')
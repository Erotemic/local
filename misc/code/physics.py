#http://stackoverflow.com/questions/11874767/real-time-plotting-in-while-loop-with-matplotlib
from __future__ import division
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import time

G = 1 # Strength of gravity
HEIGHT = 255
WIDTH = 255
DEPTH = 0

def calculate_gravity(p1, p2):
    global G
    r2 = (p1.x - p2.x)**2 + (p1.y - p2.y)**2
    force = G * (p1.mass * p2.mass) / r2 
    direction = np.array(((p2.x - p1.x), (p2.y - p1.y)))
    return force, direction

class Particle(object):
    def __init__(self):
        self.x = 0
        self.y = 0
        self.mass = 1
    def apply_force(self, force, direction):
        x_dir, y_dir = direction
        self.x += x_dir * force
        self.y += y_dir * force

class Universe(object):
    def __init__(univ):
        univ.particles = []

    def get_particle_positions(univ):
        x_list = [part.x for part in univ.particles]
        y_list = [part.y for part in univ.particles]
        return x_list, y_list

    def apply_forces(univ):
        particle_pairs = set([])
        setadd = particle_pairs.add
        # Incomprehensible list comprehension
        [None 
         for p1 in iter(univ.particles) 
         for p2 in iter(univ.particles) 
         if (not p1 is p2) and 
            ((p2, p1) not in particle_pairs) and
            (setadd((p1, p2))) ]

        for (p1, p2) in particle_pairs:
            force, direction = calculate_gravity(p1, p2)
            p1.apply_force(force, direction)
            p2.apply_force(force, -direction)

def invent_the_universe(num_particles):
    univ = Universe()
    for num in range(num_particles): 
        part = Particle()
        part.x = np.random.rand() * WIDTH
        part.y = np.random.rand() * HEIGHT
        univ.particles.append(part)
    return univ

def make_an_apple_pie():
    raise NotImplemented()

def initialize_visualization(univ):
    'Visualise the simulation using matplotlib, using blit for improved speed'
    fig, ax = plt.subplots(1,1)
    ax.set_aspect('equal')
    ax.set_xlim(0,WIDTH)
    ax.set_ylim(0,HEIGHT)
    ax.hold(True)
    fig.canvas.draw()
    background = fig.canvas.copy_from_bbox(ax.bbox) # cache the background
    x_list, y_list = univ.get_particle_positions()
    plot = ax.plot(x_list, y_list, 'o')[0]
    return plot, fig, ax, background

def next_timestep(plot, fig, ax, background, univ):
    univ.apply_forces()
    x_list, y_list = univ.get_particle_positions()
    plot.set_data(x_list,y_list)                       # update the xy data
    # BLT: 
    fig.canvas.restore_region(background)   # restore background
    ax.draw_artist(plot)                     # redraw just the points
    fig.canvas.blit(ax.bbox)                # fill in the axes rectangle

def run_timesteps(plot, fig, ax, background, univ, num_timesteps=1000):
    timestep_index = 0
    while True:
        next_timestep(plot, fig, ax, background, univ)
        timestep_index = timestep_index + 1
        if timestep_index > num_timesteps:
            break

univ = invent_the_universe(5)
plot, fig, ax, background = initialize_visualization(univ)
run_timesteps(plot, fig, ax, background, univ, num_timesteps=1000)

# -*- coding: utf-8 -*-
"""
Module for programatic Sprokit pipeline definitions

pipedef (pypedef?)

Outline / Proof-of-concept
"""
from __future__ import absolute_import, division, print_function, unicode_literals
from os.path import join, exists
import collections
from collections import OrderedDict as odict
import ubelt as ub
import os
import sys
import six

__all__ = ['Pipeline']

# ------
# Abstract classes


class Port(ub.NiceRepr):
    """ abstract port """
    def __init__(self, name, parent):
        self.name = name
        self.parent = parent

    def __nice__(self):
        return self.name

    def absname(self):
        return '{}.{}.{}'.format(self.parent.parent.name, self._direction, self.name)


class DictLike(collections.Mapping):
    """
    An inherited class must specify the ``__getitem__``, ``__setitem__``, and
      ``keys`` methods.
    """

    def keys(self):
        raise NotImplementedError('abstract keys function')

    def __delitem__(self, key):
        raise NotImplementedError('abstract __delitem__ function')

    def __getitem__(self, key):
        raise NotImplementedError('abstract __getitem__ function')

    def __setitem__(self, key, value):
        raise NotImplementedError('abstract __setitem__ function')

    def __repr__(self):
        return repr(self.to_dict())

    def __str__(self):
        return str(self.to_dict())

    def __len__(self):
        return len(list(self.keys()))

    def __contains__(self, key):
        return key in self.keys()

    def __iter__(self):
        for key in self.keys():
            yield key

    def items(self):
        if six.PY2:
            return list(self.iteritems())
        else:
            return self.iteritems()

    def values(self):
        if six.PY2:
            return [self[key] for key in self.keys()]
        else:
            return (self[key] for key in self.keys())

    def copy(self):
        return dict(self.items())

    def to_dict(self):
        return dict(self.items())

    def iteritems(self):
        for key, val in zip(self.iterkeys(), self.itervalues()):
            yield key, val

    def itervalues(self):
        return (self[key] for key in self.keys())

    def iterkeys(self):
        return (key for key in self.keys())

    def get(self, key, default=None):
        try:
            return self[key]
        except KeyError:
            return default


class PortSet(ub.NiceRepr, DictLike):
    """ abstract ordered defaultdict-like container """
    def __init__(self, parent=None):
        self.parent = parent
        self._ports = odict()
        self._frozen = False

    def __nice__(self):
        return '{}, {}'.format(self.parent.name, len(self))

    # def __iter__(self):
    #     for iport in self._ports.values():
    #         yield iport

    def keys(self):
        return self._ports.keys()

    def __getitem__(self, key):
        if key not in self._ports:
            if not self._frozen:
                self.add(key)
        return self._ports[key]

    def add(self, key):
        if self._frozen is True:
            raise RuntimeError('Port is frozen, cannot add key={}'.format(key))
        if key not in self._ports:
            self._ports[key] = self.wraped_port_type(key, self)

    def define(self, *keys):
        """
        Ensures that ports exist
        (TODO: a list of all valid ports can be gathered from sprokit
         making this unnecessary)
        """
        for key in keys:
            self.add(key)
        self._frozen = True

    def _connect(self, mapping, **kwargs):
        if mapping:
            for name, other_port in mapping.items():
                self_port = self[name]
                self_port.connect(other_port)

        for name, other_port in kwargs.items():
            # if name not in self:
            #     raise KeyError(name)
            if self._frozen:
                if name not in self:
                    continue
            self_port = self[name]
            self_port.connect(other_port)

# ----
# Classes for internal representation


class IPort(Port):
    _direction = 'in'

    def __init__(self, name, parent):
        super(IPort, self).__init__(name, parent)
        self.connections = []

    def connect(self, oport):
        # if isinstance(oport, IPort):
        if not isinstance(oport, OPort):
            raise TypeError('Cannot connect {}.iport={} to {}.iport={}'.format(
                self.parent, self, oport.parent, oport))

        print('Connect from {}.iport={} to {}.iport={}'.format(self.parent, self, oport.parent, oport))
        self.connections.append(oport)


class OPort(Port):
    _direction = 'out'

    def connect(self, iport):
        if not isinstance(iport, IPort):
            raise TypeError('Cannot connect {}.oport={} to {}.oport={}'.format(
                self.parent, self, iport.parent, iport))
        iport.connect(self)


class InputPortSet(PortSet):
    wraped_port_type = IPort

    def connect(self, mapping=None, **kwargs):
        """
        Connect input ports to output ports
        """
        self._connect(mapping, **kwargs)


class OutputPortSet(PortSet):
    wraped_port_type = OPort

    def connect(self, mapping=None, **kwargs):
        """
        Connect output ports to input ports

        (It is preferable to connect inputs to outputs to mimic the
         syntax of calling a function)
        """
        self._connect(mapping, **kwargs)

# ----
# User facing class and API


class Process(ub.NiceRepr):
    """
    Represents and maintains the definition of a pipeline node and its incoming
    and outgoing connections.
    """
    def __init__(self, type, name=None, config=None):
        self.type = type
        self.name = name
        self.config = config
        self.iports = InputPortSet(self)
        self.oports = OutputPortSet(self)

    def __nice__(self):
        return '{}::{}'.format(self.name, self.type)

    def make_node_text(self):
        """
        Creates a text based definition of this node for a .pipe file
        """
        fmtstr = ub.codeblock(
            '''
            process {name}
              :: {type}
            ''')
        parts = [fmtstr.format(name=self.name, type=self.type)]
        if self.config:
            if isinstance(self.config, six.string_types):
                parts.extend(self.config.splitlines())
            else:
                for key, val in self.config.items():
                    parts.append('  :{key} {val}'.format(key=key, val=val))
        text = '\n'.join(parts)
        return text

    def make_edge_text(self):
        """
        Creates a text based definition of all incoming conections to this node
        for a .pipe file
        """
        fmtstr = ub.codeblock(
            '''
            connect from {oport_abs_name}
                    to   {iport_abs_name}
            ''')
        parts = []
        for iport in self.iports.values():
            for oport in iport.connections:
                if oport is not None:
                    part = fmtstr.format(
                        oport_abs_name=oport.absname(),
                        iport_abs_name=iport.absname(),
                    )
                    parts.append(part)
        text = '\n'.join(parts)
        return text


class Pipeline(object):
    """
    Defines a Sprokit pipeline

    Example:
        >>> from define_pipeline import *  # NOQA
        >>> pipe = Pipeline()
        >>> # Pipeline nodes
        >>> input_image = pipe.add_process(
        ...     name='input_image', type='frame_list_input', config={
        ...         'image_list_file': 'input_list.txt',
        ...         'frame_time': 0.03333333,
        ...         'image_reader:type': 'ocv',
        ...     })
        >>> detector = pipe.add_process(
        ...     name='detector', type='hello_world_detector', config={
        ...         'text': 'Hello World!! (from python)',
        ...     })
        >>> # Connections
        >>> detector.iports.connect({
        ...     'image': detector.oports['image'],
        ... })
        >>> # Global config
        >>> pipe.config['_pipeline:_edge']['capacity'] = 5
        >>> pipe.config['_scheduler']['type'] = 'pythread_per_process'
        >>> # write the pipeline file to disk
        >>> pipe.write('hello_world_python.pipe')
        >>> # Draw the pipeline using graphviz
        >>> pipe.draw_graph('hello_world_python.png')
        >>> # Directly run the pipeline
        >>> pipe.run()
    """
    def __init__(self):
        # Store defined processes in a dictionary
        self.procs = odict()

        # Global configuration
        # TODO: determine the best way to represent this
        self.config = {
            '_pipeline:_edge': {
                # 'capacity': None,
            },
            '_scheduler': {
                # 'type': 'pythread_per_process',
            }
        }

    def add_process(self, type, name=None, config=None):
        """
        Adds a new process node to the pipeline.
        """
        assert name is not None, 'must specify name for now'
        node = Process(type=type, name=name, config=config)
        self.procs[name] = node
        return node

    def __getitem__(self, key):
        return self.procs[key]

    def make_global_text(self):
        """

        Ignore:
            # TODO: determine the best way to represent global configs
            # Ways end results can look:

            config _pipeline:_edge
                   :capacity 10

            config _scheduler
               :type pythread_per_process
        """
        # Note sure this is exactly how global configs are given yet
        lines = []
        for key, val in self.config.items():
            if val:
                lines.append('config {key}'.format(key=key))
                for key2, val2 in val.items():
                    lines.append('    :{key2} {val2}'.format(
                        key2=key2, val2=val2))
        text = '\n'.join(lines)
        return text

    def make_pipeline_text(self):
        blocks = []

        blocks.append(ub.codeblock(
            '''
            # ----------------------
            # nodes
            #
            '''))
        for proc in self.procs.values():
            node_text = proc.make_node_text()
            if node_text:
                blocks.append(node_text)

        blocks.append(ub.codeblock(
            '''
            # ----------------------
            # connections
            #
            '''))
        for proc in self.procs.values():
            edge_text = proc.make_edge_text()
            if edge_text:
                blocks.append(edge_text)

        blocks.append(ub.codeblock(
            '''
            # ----------------------
            # global pipeline config
            #
            '''))
        blocks.append(self.make_global_text())

        text = '\n\n'.join(blocks)
        return text

    def write(self, fpath):
        print('writing pipeline filepath = {!r}'.format(fpath))
        text = self.make_pipeline_text()
        with open(fpath, 'w') as file:
            file.write(text)

    def run(self, dry=False):
        """
        Executes this pipeline.

        Writes a temporary pipeline file to your sprokit cache directory and
        calls the pipeline_runner.
        """
        cache_dir = ub.ensure_app_cache_dir('sprokit', 'temp_pipelines')
        # TODO make a name based on a hash of the text to avoid race conditions
        pipe_fpath = join(cache_dir, 'temp_pipeline_file.pipe')
        self.write(pipe_fpath)
        run_pipe_file(pipe_fpath, dry=dry)

    def to_networkx(self):
        """
        Creates a networkx representation of the process graph.

        Useful for visualization / any network graph analysis
        """
        import networkx as nx
        G = nx.DiGraph()
        # G.graph.update(self.config)

        if nx.__version__.startswith('1'):
            node_dict = G.node
        else:
            node_dict = G.nodes

        def _defaultstyle(node, color, shape='none', **kwargs):
            node_dict[node]['fillcolor'] = color
            node_dict[node]['style'] = 'filled'
            node_dict[node]['shape'] = shape
            node_dict[node].update(kwargs)
            # node_dict[node]['color'] = color

        # Add all processes
        # Make inputs and outputs nodes to prevent needing a multigraph
        for proc in self.procs.values():
            G.add_node(proc.name)
            _defaultstyle(proc.name, 'turquoise', shape='ellipse', fontsize=20)

            for iport in proc.iports.values():
                iport_name = iport.absname()
                G.add_node(iport_name)
                G.add_edge(iport_name, proc.name)
                node_dict[iport_name]['label'] = iport.name
                _defaultstyle(iport_name, '#fefefe', fontsize=14)

            for oport in proc.oports.values():
                oport_name = oport.absname()
                G.add_node(oport_name)
                G.add_edge(proc.name, oport_name)
                node_dict[oport_name]['label'] = oport.name
                _defaultstyle(oport_name, '#f0f0f0', fontsize=14)

        # Add all connections
        for proc in self.procs.values():
            for iport in proc.iports.values():
                iport_name = iport.absname()
                for oport in iport.connections:
                    if oport is not None:
                        oport_name = oport.absname()
                        G.add_edge(oport_name, iport_name)
        return G

    def draw_graph(self, fpath):
        """
        Draws the process graph using graphviz

        PreReqs:
            sudo apt-get install graphviz libgraphviz-dev pkg-config
            pip install networkx pygraphviz

            # fishlen_pipeline.py
        """
        import networkx as nx
        G = self.to_networkx()
        A = nx.nx_agraph.to_agraph(G)

        for proc in self.procs.values():
            nbunch = [proc.name]
            nbunch += [iport.absname() for iport in proc.iports.values()]
            nbunch += [oport.absname() for oport in proc.oports.values()]
            A.add_subgraph(
                nbunch, name='cluster_' + proc.name,
                color='lightgray', style='filled', fillcolor='lightgray')
            # color=lightgray;style=filled;fillcolor=lightgray;
        A.layout(prog='dot')
        A.draw(fpath)


def find_pipeline_runner():
    """
    Search for the sprokit pipeline_runner executable
    """
    # First check if pipeline_runner is specified as an environment variable
    runner_fpath = os.environ.get('SPROKIT_PIPELINE_RUNNER', None)
    if runner_fpath is not None:
        return runner_fpath

    # If not, then search for the binary in the current dir and the PATH
    fnames = ['pipeline_runner']
    if sys.platform.startswith('win32'):
        fnames.insert(0, 'pipeline_runner.exe')

    search_paths = ['.']
    search_paths = os.environ.get('PATH', '').split(os.pathsep)

    for fname in fnames:
        for dpath in search_paths:
            fpath = join(dpath, fname)
            if os.path.isfile(fpath):
                return fpath


def run_pipe_file(pipe_fpath, dry=False):
    """
    Executes pipeline_runner with a specific pipe file.
    """
    import os
    runner_fpath = find_pipeline_runner()
    # '/home/joncrall/code/VIAME/build/install/bin/pipeline_runner'

    print('found runner exe = {!r}'.format(runner_fpath))

    if not exists(pipe_fpath):
        raise IOError('Pipeline file {} does not exist'.format(pipe_fpath))

    if not exists(runner_fpath):
        raise NotImplementedError('Cannot find pipeline_runner')

    command = '{} -p {}'.format(runner_fpath, pipe_fpath)
    print('command = "{}"'.format(command))
    if not dry:
        os.system(command)

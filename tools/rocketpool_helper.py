#!/usr/bin/env python3
import scriptconfig as scfg
import ubelt as ub
import rich


class RocketPoolHelper(scfg.ModalCLI):
    """
    Modal CLI for my rocketpool helpers
    """


@RocketPoolHelper.register
class ValidatorDuties(scfg.DataConfig):
    """
    Example:

        python ~/local/tools/rocketpool_helper.py duties

    """
    __command__ = 'duties'
    indices = scfg.Value('auto', nargs='*', help='validator indices')

    @classmethod
    def main(cls, cmdline=1, **kwargs):
        import sys
        sys.path.append(ub.expandpath('~/local/tools'))
        import get_validator_duties
        config = cls.cli(cmdline=cmdline, data=kwargs, strict=True)
        rich.print('config = ' + ub.urepr(config, nl=1))
        get_validator_duties.main(config.indices)

if __name__ == '__main__':
    """

    CommandLine:
        python -m rocketpool_helper duties
    """
    RocketPoolHelper.main()

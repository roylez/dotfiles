# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# You always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import *

# A simple command for demonstration purposes follows.
# -----------------------------------------------------------------------------

# You can import any python module as needed.
import os

class rename_images(Command):
    # The so-called doc-string of the class will be visible in the built-in
    # help that is accessible by typing "?c" inside ranger.
    """:rename_images

    Batch renaming images based on filename order
    """

    # The execute method is called when you run this command in ranger.
    def execute(self):
        d = self.fm.thisfile
        
        if d.is_directory:
            renamecmd = [ os.path.expanduser("~/.config/ranger/rename_images.zsh"), str(d) ]
            self.fm.run( renamecmd )
        else:
            self.fm.notify("Not a directory!")

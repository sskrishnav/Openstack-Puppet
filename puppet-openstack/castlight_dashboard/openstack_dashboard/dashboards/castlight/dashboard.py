from django.utils.translation import ugettext_lazy as _

import horizon


class Castlight(horizon.Dashboard):
    name = _("castlight")
    slug = "castlight"
    panels = ()  # Add your panels here.
    default_panel = ''  # Specify the slug of the default panel.


#horizon.register(Castlight)
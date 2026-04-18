import Toybox.Lang;
import Toybox.Graphics;

// Reusable array types
typedef GarminFont as FontDefinition or VectorFont;
typedef ArrayOfGarminFonts as Array<GarminFont>;

// Types used to manage UI resources
typedef ResourceSet as WidgetResourceSet or GlanceResourceSet;
typedef EvccFont as WidgetResourceSetBase.Font or GlanceResourceSet.Font;
typedef EvccIcons as Array<Array<ResourceId?>>;




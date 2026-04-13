import Toybox.Lang;
import Toybox.Graphics;

// Reusable array types
typedef ArrayOfSiteViews as Array<EvccSiteViewBase>;
typedef ArrayOfLoadPoints as Array<Loadpoint>;
typedef GarminFont as FontDefinition or VectorFont;
typedef ArrayOfGarminFonts as Array<GarminFont>;
typedef LoadPointCategory as [ IconBlock.Icon, LoadpointList ];

typedef JsonContainer as Dictionary<String,Object?>;

// Types used to manage UI resources
(:exclForGlanceTiny :exclForGlanceNone) typedef ResourceSet as WidgetResourceSet or GlanceResourceSet;
(:exclForGlanceTiny :exclForGlanceNone) typedef EvccFont as WidgetResourceSetBase.Font or GlanceResourceSet.Font;
(:exclForGlanceFull) typedef ResourceSet as WidgetResourceSet;
(:exclForGlanceFull) typedef EvccFont as WidgetResourceSetBase.Font;
typedef EvccIcons as Array<Array<ResourceId?>>;




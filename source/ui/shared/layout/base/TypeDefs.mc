import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

// Defines all the possible options used in drawing blocks
// See DrawingBlockBase documentation for details
typedef DbOptions as {
    :dc as EvccDcInterface?,
    :parent as ContainerBlock or WeakReference or Null,
    :justify as TextJustification?,
    :verticalJustifyToBaseFont as Boolean?,
    :marginLeft as Numeric?,
    :marginRight as Numeric?,
    :marginTop as Numeric?,
    :marginBottom as Numeric?,
    :spreadToHeight as Numeric?,
    :color as ColorType?,
    :backgroundColor as ColorType?,
    :font as EvccFont?,
    :baseFont as EvccFont?,
    :relativeFont as Number?,
    :isTruncatable as Boolean?,
    :useEllipsis as Boolean?,
    :truncateSpacing as Number?,
    :batterySoc as Number?,
    :power as Number?,
    :activePhases as Number?,
    :relativeToScreenWidth as Float?,
    :relativeToScreenHeight as Float?
};

// Defines all the possible values, needs to duplicate all types used in DbOptions
typedef DbOptionValue as EvccDcInterface or ContainerBlock or WeakReference or TextJustification or Boolean or Numeric or ColorType or EvccFont or Null;

// CIQ3 and before uses BitmapResource, CIQ4+ uses BitmapReference since bitmaps are 
// stored in a separate graphics pool. We need to support both.
typedef DbBitmap as BitmapResource or BitmapReference;

// This interface describes the capabilities needed from the Dc when
// pre-rendering views. This way either a real Dc or the DcStub
// can be used for the pre-rendering, depending on what is available.
typedef EvccDcInterface as interface {
    function getWidth() as Number;
    function getHeight() as Number;
    function getTextWidthInPixels( text as String, font as FontType ) as Number;
};
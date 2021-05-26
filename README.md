# TB-contouring-GUI

## Requirements
- MATLAB R2019b

## Functions
- *Load File* button: load files in .mat format only.
- `Draw ROI` button: [drawfreehand](https://www.mathworks.com/help/images/ref/drawfreehand.html)
- 'Save All' button:
  -  If there exist ROI on the current axes, then the binary of the ROI will be recorded. If alreadly exist ROI drwan previously, then the question dialog will show up and ask whether you want to overwrite the previous record.
  -  If there is not ROI, then the filename will be recorded in an excel file.
- 'Show Previous ROI' button
  - If there exist previously saved ROI, then after clicking the button, the ROI will be shown on the current axes.
  - If there is no previously drawn ROI, then you are unable to click the button.

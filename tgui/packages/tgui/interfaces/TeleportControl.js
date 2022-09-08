import { Box, Button, Section, Table, DraggableClickableControl, Dropdown, Divider, NoticeBox, ProgressBar, ScrollableBox, Flex, OrbitalMapComponent, OrbitalMapSvg, Input, Slider } from '../components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { toArray } from '../../common/collections';
import { ButtonCheckbox } from '../components/Button';

export const TeleportControl = (props, context) => {
    const { act, data } = useBackend(context);
    const {
        points,
        rounded_points,
        blocked_points,
        point_limit,
        inverted,
        active,
        stability,
    } = data;

    const [
        xOffset,
        setXOffset,
    ] = useLocalState(context, 'xOffset', 0);
    let dynamicXOffset = xOffset;
    const [
        yOffset,
        setYOffset,
    ] = useLocalState(context, 'yOffset', 0);
    let dynamicYOffset = yOffset
    const [
        zoomScale,
        setZoomScale,
      ] = useLocalState(context, 'zoomScale', 1);

    const lineStyle = {
        stroke: '#BBBBBB',
        strokeWidth: '2',
        };
    const velLineStyle = {
        stroke: '#00FF00',
        strokeWidth: '2',
        };

  return (
    <Window
        width={700}
        height={650}>
        <Window.Content fitted>
            <Box>{dynamicXOffset}</Box>
            <ProgressBar value={stability}ranges={{
            good: [0.5, Infinity],
            average: [0.25, 0.5],
            bad: [-Infinity, 0.25],}}>Stability</ProgressBar>

            <PlotDisplay
            xOffset={dynamicXOffset}
            yOffset={dynamicYOffset}
            zoomScale={zoomScale}
            setZoomScale={setZoomScale}
            setXOffset={setXOffset}
            setYOffset={setYOffset} />

            <Box flow>
                {`Y = `}
                <Input flow
                onChange={(e, value) => {act("compile_formula", {points: compile_formula(value)})}}/>
                <Button
                color={`${active ? "red" : "green"}`}
                onClick={(e, value) => {act(`${active ? 'close' : 'activate'}`)}}>{`${active ? 'Close' : 'Activate'}`}</Button>
                <ButtonCheckbox checked={inverted} onClick={(e, value) => {act("invert")}}> 
                    Invert
                </ButtonCheckbox>
            </Box>
            <Box>
                <Slider value={point_limit} minValue={0} maxValue={300} onChange={(e, value) => {act("input_limit", {limit: value})}}/>
            </Box>
        </Window.Content>
    </Window>
  );
};

export const PlotDisplay = (props, context) => {
    const { act, data } = useBackend(context);
    const {
        xOffset,
        yOffset,
        zoomScale,
        setXOffset,
        setYOffset,
    } = props;
    const {
        points,
        rounded_points,
        blocked_points,
        effects_points,
        point_limit,
        inverted,
        active,
        stability,
    } = data;
    let lockedZoomScale = Math.max(Math.min(zoomScale, 4), 0.125);
    return(
        <DraggableClickableControl
        position="absolute"
        value={xOffset}
        dragMatrix={[-1, 0]}
        step={1}
        stepPixelSize={2 * zoomScale}
        onDrag={(e, value) => {
          setXOffset(value);
        }}
        onClick={(e, value) => {}}
        updateRate={5}>
        {control => (
          <DraggableClickableControl
            position="absolute"
            value={yOffset}
            dragMatrix={[0, -1]}
            step={1}
            stepPixelSize={2 * zoomScale}
            onDrag={(e, value) => {
              setYOffset(value);
            }}
            onClick={(e, value) => {}}
            updateRate={5}>
            {control1 => (
              <>
                {control.inputElement}
                {control1.inputElement}
                <svg
                  onMouseDown={e => {
                    control.handleDragStart(e);
                    control1.handleDragStart(e);
                  }}
                  height="512px"
                  width="720px"
                  viewBox="0 0 100% 100%"
                  position="absolute"
                  overflowY="hidden">
                        <defs>
                          <pattern id="grid" width={32*lockedZoomScale} height={32*lockedZoomScale} patternUnits="userSpaceOnUse" 
                            x={-xOffset * zoomScale}
                            y={-yOffset * zoomScale}>
                              <rect width={32*lockedZoomScale} height={32*lockedZoomScale} fill="url(#smallgrid)" />
                              <path d={"M " + (32*lockedZoomScale) + " 0 L 0 0 0 " + (32*lockedZoomScale)} fill="none" stroke="#4665DE" stroke-width="1" />
                          </pattern>
                          <pattern id="smallgrid" width={16*lockedZoomScale} height={16*lockedZoomScale} patternUnits="userSpaceOnUse">
                              <rect width={16*lockedZoomScale} height={16*lockedZoomScale} fill="#2B2E3B" />
                              <path d={"M " + (16*lockedZoomScale) + " 0 L 0 0 0 " + (16*lockedZoomScale)} fill="none" stroke="#4665DE" stroke-width="0.5" />
                          </pattern>
                        </defs>
                        <rect width={"100%"} height="100%" fill="url(#grid)" />
                        {blocked_points.map(point => <rect
                            //blocked points
                            x={`${(((point.x*16)+352)-xOffset)*zoomScale}`}
                            y={`${(((-point.y*16)+256)-yOffset)*zoomScale}`}
                            width="16px"
                            height="16px"
                            stroke="rgba(25,25,25,128)"
                            stroke-width="1"
                            fill="rgba(25,25,25,128)" />)}
                        {effects_points.map(point => <rect
                            //effects points
                            x={`${(((point.x*16)+352)-xOffset)*zoomScale}`}
                            y={`${(((-point.y*16)+256)-yOffset)*zoomScale}`}
                            width="16px"
                            height="16px"
                            stroke="rgba(255,25,225,128)"
                            stroke-width="1"
                            fill="rgba(255,25,255,128)" />)} 
                        {rounded_points.map(point => <rect
                            //rounded points
                            x={`${(((point.x*16)+352)-xOffset)*zoomScale}`}
                            y={`${(((-point.y*16)+256)-yOffset)*zoomScale}`}
                            width="16px"
                            height="16px"
                            stroke="rgba(100,255,100,128)"
                            stroke-width="1"
                            fill="rgba(100,255,100,128)" />)}
                        {points.map(point => <circle
                            //float points
                            cx={`${((point.x*16)+360-xOffset)*zoomScale}`}
                            cy={`${((-point.y*16)+264-yOffset)*zoomScale}`}
                            r="2px"
                            stroke="rgba(255,255,255,255)"
                            stroke-width="1"
                            fill="rgba(255,255,255,255)" />)} 
                </svg>
              </>
            )}
          </DraggableClickableControl>
        )}
      </DraggableClickableControl>
    );
};

function compile_formula(value){
    const points = []
    for(let i = 1; i < 300; i+=1){
        let text = value.replace(/x/g, i);
        points[i] = eval(text)
    }
    return points;
}

function sin(value){
    return Math.sin(value);
}

function arcsin(value){
    return Math.asin(value)
}

function cos(value){
    return Math.cos(value);
}

function arccos(value){
    return Math.acos(value);
}

function tan(value){
    return Math.tan(value);
}

function arctan(value){
    return Math.atan(value);
}

function abs(value){
    return Math.abs(value);
}

function sqrt(value){
    return Math.sqrt(value);
}

function log (value){
    return Math.log(value);
}

function inverse (value){
    return Math.inverse(value);
}

function exp (value){
    return Math.exp(value);
}

function pow (value, value_e){
    return Math.pow(value, value_e);
}

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
    } = data;

    const [
        xOffset,
        setXOffset,
      ] = useLocalState(context, 'xOffset', 0);
    const [
    yOffset,
    setYOffset,
    ] = useLocalState(context, 'yOffset', 0);

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
        height={600}>
        <Window.Content fitted>
            <Box>{`${xOffset}`}</Box>
            <DraggableClickableControl
            position="absolute"
            value={1}
            dragMatrix={[-1, 0]}
            step={1}
            stepPixelSize={2 * 1}
            onDrag={(e, value) => {setXOffset(value)}}
            onClick={(e, value) => {}}
            updateRate={5}>
                {control => (
                    <svg
                        position="absolute"
                        height="512px"
                        width="720px"
                        viewBox="0 0 100% 100%">
                        <defs>
                            <pattern id="grid" width={32} height={32} patternUnits="userSpaceOnUse">
                                <rect width={32} height={32} fill="url(#smallgrid)" />
                                <path d={"M 32 0 L 0 0 0 32"} fill="none" stroke="#4665DE" stroke-width="1" />
                            </pattern>
                            <pattern id="smallgrid" width={16} height={16} patternUnits="userSpaceOnUse">
                                <rect width={16} height={16} fill="#2B2E3B" />
                                <path d={"M 16 0 L 0 0 0 16"} fill="none" stroke="#4665DE" stroke-width="0.5" />
                            </pattern>
                        </defs>
                        <rect width="100%" height="100%" fill="url(#grid)" />
                        {rounded_points.map(point => <rect
                            //rounded points
                            x={`${(point.x*16)+352}`}
                            y={`${(-point.y*16)+256}`}
                            width="16px"
                            height="16px"
                            stroke="rgba(100,255,100,128)"
                            stroke-width="1"
                            fill="rgba(100,255,100,128)" />)}
                        {blocked_points.map(point => <rect
                            //blocked points
                            x={`${(point.x*16)+352}`}
                            y={`${(-point.y*16)+256}`}
                            width="16px"
                            height="16px"
                            stroke="rgba(25,25,25,128)"
                            stroke-width="1"
                            fill="rgba(25,25,25,128)" />)} 
                        {points.map(point => <circle
                            //float points
                            cx={`${(point.x*16)+360}`}
                            cy={`${(-point.y*16)+264}`}
                            r="2px"
                            stroke="rgba(255,255,255,255)"
                            stroke-width="1"
                            fill="rgba(255,255,255,255)" />)}          
                    </svg>
                )}
            </DraggableClickableControl>
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

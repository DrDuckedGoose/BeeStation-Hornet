import { map, toArray } from 'common/collections';
import { classes } from 'common/react';
import { render } from 'inferno';
import { useBackend } from '../backend';
import { Box, Tabs, Section, Flex, Button, BlockQuote, Icon, Collapsible, AnimatedNumber, Table } from '../components';
import { ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

export const SlimeCombinator = (props, context) => {
	const { act, data } = useBackend(context);
	const current_tab=(data.tab);
return (
	<Window
	width={450}
	height={460}>
	<Window.Content scrollable>
		<Flex>
			{current_tab === "Select-Initial" && (
			<SlimeOptions_Parent/>)}

			{current_tab === "Promote-Outcomes" && (
			<SlimeOptions_Child/>)}
		</Flex>
	</Window.Content>
	</Window>
);
};

const SlimeOptions_Parent = (props, context) => {
	const { act, data } = useBackend(context);
	const slimes=toArray(data.all_slimes);
	const parent_slimes=toArray(data.parent_slimes);
return (
	<Box>
		<Flex.Item p={0.5}>
			<Section>
			{parent_slimes.length ? parent_slimes.map(slime => (<SlimeEntry slime = {slime} key = {slime}/>)) : "No Selected Samples."}
			</Section>
		</Flex.Item>

		<Flex.Item p={0.5}>
			<Section>
				{slimes.length ? slimes.map(slime => (<SlimeEntry slime = {slime} key = {slime}/>)) : "No samples detected."}
			</Section>
		</Flex.Item>

		{parent_slimes.length > 1 && (<Flex.Item p={0.5}>
			<Section>
				<Button onClick={() => act('combine-selected')}>
					Queue Simulation
				</Button>
			</Section>
		</Flex.Item>)}
	</Box>
);
};

const SlimeOptions_Child = (props, context) => {
	const { act, data } = useBackend(context);
	const litter_slimes=toArray(data.litter_slimes);
	const parent_slimes=toArray(data.parent_slimes);
return (
	<Box>
		<Flex.Item p={1}>
			<Section>
			{parent_slimes.length ? parent_slimes.map(slime => (<SlimeEntry slime = {slime} key = {slime}/>)) : "No Selected Samples."}
			</Section>
		</Flex.Item>

		<Flex.Item p={1}>
			<Section>
			{litter_slimes.length ? litter_slimes.map(slime => (<SlimeEntry slime = {slime} key = {slime}/>)) : "No generated samples."}
			</Section>
		</Flex.Item>

		{parent_slimes.length > 1 && (<Flex.Item p={0.5}>
			<Section>
				<Button onClick={() => act('combine-selected')}>
				Requeue Simulation
				</Button>
			</Section>
		</Flex.Item>)}

		{parent_slimes.length === 1 && (<Flex.Item p={0.5}>
			<Section>
				<Button onClick={() => act('choose-selected')}>
					Select Sample
				</Button>
			</Section>
		</Flex.Item>)}
	</Box>
);
};

const SlimeEntry = (props, context) => {
	const { act, data } = useBackend(context);
	const {
		slime,
	} = props;
return (
	<Button tooltip={slime.name} onClick={() => act('select-slime', {ref : slime.self_ref,})}>
		<Box>
			{<img
			src={`data:image/jpeg;base64,${slime.img}`}
			style={{
				'vertical-align': 'middle',
				'horizontal-align': 'middle',
			}} />}
		</Box>
	</Button>
);
};

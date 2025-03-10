import { useBackend } from '../backend';
import { Button, Section, Box, Flex, Input, BlockQuote, Divider, Icon, Dimmer } from '../components';
import { Window } from '../layouts';

export const PlantEditor = (props) => {
  const { act, data } = useBackend();
  const {
    plant_feature_data,
    inserted_plant,
    saving_feature,
  } = data;
  return (
    <Window width={600} height={500}>
      <Window.Content scrollable={0}>
        {inserted_plant ? <InUseBody /> : <EmptyBody /> }
        {saving_feature ? <SavingPlantFeature /> : <EmptyBody />}
      </Window.Content>
    </Window>
  );
};

const SavingPlantFeature = (props) => {
  const { act, data } = useBackend();
  const {
    current_feature,
    current_feature_traits,
  } = data;
  return (
    <Dimmer>
      <Flex direction='column'>
        <Flex.Item>
          Choose Which Traits To Save With The Feature
        </Flex.Item>

        <Flex.Item m={0.1} />

        {current_feature_traits ? current_feature_traits.map((data_set) => (
          <PlantTraitInstance title={data_set["trait_name"]} body={data_set["trait_desc"]} trait_key={data_set["trait_ref"]} mode={1} key={data_set} />
        )) : `No Traits Found`}

        <Flex.Item m={0.1} />

        <Button onClick={() => act('save_feature', { key : current_feature, force : 1 })}>
            <Icon name="plus" />
        </Button>
      </Flex>
    </Dimmer>
  );
};

const EmptyBody = (props) => {
  const { act, data } = useBackend();
  return (
    <Box textAlign='center'>
      Please Insert Plant
    </Box>
  );
};

const InUseBody = (props) => {
  const { act, data } = useBackend();
  const {
    plant_feature_data,
    inserted_plant,
    current_feature,
  } = data;
  return (
    <Flex direction='row'>

      <Flex.Item width='35%'>
        <Section>
          {inserted_plant}
          <Divider />
          <Flex direction='column'>
            {plant_feature_data.map((feature_data) => (<PlantFeatureTab feature={feature_data} key={feature_data} />))}
          </Flex>
        </Section>
      </Flex.Item>

      <Flex.Item m={0.1} />

      <Flex.Item width='65%' height='100%' grow>
        <Section>
          <Box height={100} textAlign='center'>
            {current_feature ? <PlantDataTab /> : <EmptyBody />}
          </Box>
        </Section>
      </Flex.Item>

    </Flex>
  );
};

const PlantDataTab = (props) => {
  const { act, data } = useBackend();
  const {
    current_feature,
    current_feature_data,
    current_feature_traits,
  } = data;
  return (
    <Flex direction="column">
      <Button onClick={() => act('save_feature', { key : current_feature })}>
        <Icon name="plus" />
      </Button>

      {current_feature_data.map((data_set) => (
        data_set["data_title"] ? <PlantDataInstance title={data_set["data_title"]} body={data_set["data_field"]} key={data_set} /> : <Divider key={data_set} />
      ))}

      <Flex.Item my={0.2} />

      {current_feature_traits ? current_feature_traits.map((data_set) => (
        <PlantTraitInstance title={data_set["trait_name"]} body={data_set["trait_desc"]} trait_key={data_set["trait_ref"]} key={data_set} />
      )) : `No Traits Found`}
    </Flex>
  );
};

const PlantTraitInstance = (props) => {
  const { act, data } = useBackend();
  const { title, body, trait_key, mode } = props;
  const {
    save_excluded_traits,
  } = data;
  return (
    <Flex.Item direction="row">
      <Box backgroundColor="purple">
        <b>{title}</b>
        <Divider />
        {body}
        <Box my={0.1} />
        { mode ?
          <Button.Checkbox checked={!save_excluded_traits.includes(trait_key)} onClick={() => act('toggle_trait', { key : trait_key })}>
            Include Trait
          </Button.Checkbox>
          :
          <Button onClick={() => act('save_trait', { key : trait_key })}>
            <Icon name="plus" />
          </Button>
        }
      </Box>
    </Flex.Item>
  );
};

const PlantDataInstance = (props) => {
  const { act, data } = useBackend();
  const { title, body } = props;
  return (
    <Flex.Item>
      <b>{title}</b>: {body}
    </Flex.Item>
  );
};

const PlantFeatureTab = (props) => {
  const { act, data } = useBackend();
  const { feature } = props;
  const {
    current_feature,
  } = data;
  return (
    <Flex.Item>
      <Button width='100%' my={0.5} onClick={() => act('select_feature', { key : feature["key"] })}
        selected={feature["key"] === current_feature} >
        {`${feature["species_name"]} - ${feature["key"]}`}
      </Button>
    </Flex.Item>
  );
};

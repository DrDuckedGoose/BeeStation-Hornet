/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Warlockd
 * @license MIT
 */

import { classes } from 'common/react';
import { Component, createRef } from 'react';
import { Box } from './Box';
import { toInputValue } from './Input';
import { isEscape, KEY } from 'common/keys';

export class TextArea extends Component {
  constructor(props) {
    super(props);
    this.textareaRef = props.innerRef || createRef();
    this.fillerRef = createRef();
    this.state = {
      editing: false,
    };
    const { dontUseTabForIndent = false } = props;
    this.handleOnInput = (e) => {
      const { editing } = this.state;
      const { onInput } = this.props;
      if (!editing) {
        this.setEditing(true);
      }
      if (onInput) {
        onInput(e, e.target.value);
      }
    };
    this.handleOnChange = (e) => {
      const { editing } = this.state;
      const { onChange } = this.props;
      if (editing) {
        this.setEditing(false);
      }
      if (onChange) {
        onChange(e, e.target.value);
      }
    };
    this.handleKeyPress = (e) => {
      const { editing } = this.state;
      const { onKeyPress } = this.props;
      if (!editing) {
        this.setEditing(true);
      }
      if (onKeyPress) {
        onKeyPress(e, e.target.value);
      }
    };
    this.handleKeyDown = (e) => {
      const { editing } = this.state;
      const { onChange, onInput, onEnter, onKey } = this.props;
      if (e.key === KEY.Enter) {
        this.setEditing(false);
        if (onChange) {
          onChange(e, e.target.value);
        }
        if (onInput) {
          onInput(e, e.target.value);
        }
        if (onEnter) {
          onEnter(e, e.target.value);
        }
        if (this.props.selfClear) {
          e.target.value = '';
          e.target.blur();
        }
        return;
      }
      if (isEscape(e.key)) {
        if (this.props.onEscape) {
          this.props.onEscape(e);
        }
        this.setEditing(false);
        if (this.props.selfClear) {
          e.target.value = '';
        } else {
          e.target.value = toInputValue(this.props.value);
          e.target.blur();
        }
        return;
      }
      if (!editing) {
        this.setEditing(true);
      }
      // Custom key handler
      if (onKey) {
        onKey(e, e.target.value);
      }
      if (!dontUseTabForIndent) {
        if (e.key === KEY.Tab) {
          e.preventDefault();
          const { value, selectionStart, selectionEnd } = e.target;
          e.target.value = value.substring(0, selectionStart) + '\t' + value.substring(selectionEnd);
          e.target.selectionEnd = selectionStart + 1;
        }
      }
    };
    this.handleFocus = (e) => {
      const { editing } = this.state;
      if (!editing) {
        this.setEditing(true);
      }
    };
    this.handleBlur = (e) => {
      const { editing } = this.state;
      const { onChange } = this.props;
      if (editing) {
        this.setEditing(false);
        if (onChange) {
          onChange(e, e.target.value);
        }
      }
    };
  }

  componentDidMount() {
    const nextValue = this.props.value;
    const input = this.textareaRef.current;
    if (input) {
      input.value = toInputValue(nextValue);
    }
    if (this.props.autoFocus || this.props.autoSelect) {
      setTimeout(() => {
        input.focus();
        if (this.props.autoSelect) {
          input.select();
        }
      }, 1);
    }
  }

  componentDidUpdate(prevProps, prevState) {
    const prevValue = prevProps.value;
    const nextValue = this.props.value;
    const input = this.textareaRef.current;
    if (input && typeof nextValue === 'string' && prevValue !== nextValue) {
      input.value = toInputValue(nextValue);
    }
  }

  setEditing(editing) {
    this.setState({ editing });
  }

  getValue() {
    return this.textareaRef.current && this.textareaRef.current.value;
  }

  render() {
    // Input only props
    const {
      onChange,
      onKeyDown,
      onKeyPress,
      onInput,
      onFocus,
      onBlur,
      onEnter,
      value,
      maxLength,
      placeholder,
      scrollbar,
      noborder,
      ...boxProps
    } = this.props;
    // Box props
    const { className, fluid, ...rest } = boxProps;
    return (
      <Box
        className={classes([
          'TextArea',
          fluid && 'TextArea--fluid',
          fluid && 'TextArea--fluid',
          noborder && 'TextArea--noborder',
          className,
        ])}
        {...rest}>
        <textarea
          ref={this.textareaRef}
          className={classes(['TextArea__textarea', scrollbar && 'TextArea__textarea--scrollable'])}
          placeholder={placeholder}
          onChange={this.handleOnChange}
          onKeyDown={this.handleKeyDown}
          onKeyPress={this.handleKeyPress}
          onInput={this.handleOnInput}
          onFocus={this.handleFocus}
          onBlur={this.handleBlur}
          maxLength={maxLength}
        />
      </Box>
    );
  }
}

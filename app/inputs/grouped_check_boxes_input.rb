# frozen_string_literal: true

class GroupedCheckBoxesInput < Formtastic::Inputs::CheckBoxesInput

	# => "<li class=\"grouped_check_boxes check_boxes input optional\" >...</li>"
	# we want to reuse existing CSS from regular checkboxes
	#
	def as
		super + " check_boxes"
	end


	# input_wrapping        # => "<li class=\"grouped_check_boxes input optional\" id=\"project_technologies_input\">\n\n</li>"
	# hidden_field_for_all  # => "<input type=\"hidden\" name=\"project[technology_ids][]\" id=\"project_technologies_none\" value=\"\" autocomplete=\"off\" />"
	#
	def to_html
		input_wrapping do
			hidden_field_for_all << fieldsets_for_groups
		end
	end


	# legend_html       # => "<legend class=\"label\"><label>Technologies</label></legend>"
	# choices_wrapping  # => "<fieldset class=\"choices\"></fieldset>"
	#
	def fieldsets_for_groups
		grouped_collection.
		map { |group_method_call_return_value, group_records|
			choices_wrapping do
				legend_html(group_method_call_return_value) << lis_with_checkboxes(group_records)
			end
		}.join("\n").html_safe
	end


	def choices_wrapping_html_options
		{ class: ["choices", "grouped_check_boxes__choices"] }
	end


	def legend_html(group_method_call_return_value)
		template.content_tag :legend, label_html_options.merge(class: ["label", "grouped_check_boxes__legend"]) do
			template.content_tag :label, class: "grouped_check_boxes__legend__label" do
				acc = []
				acc << (label_text + " / ") if input_options[:group_label_parent]
				acc << group_name(group_method_call_return_value)
				acc.join("\n").html_safe
			end
		end
	end


	# choices_group_wrapping  # => <ol class="choices-group">...</ol>
	#
	def lis_with_checkboxes(records)
		choices_group_wrapping do
			choices_group_contents(records)
		end
	end


	def choices_group_wrapping_html_options
		{ class: ["choices-group", "grouped_check_boxes__choices-group"] }
	end


	# @return [String] of concatenated <li>s
	#
	def choices_group_contents(group_choice_records)
		normalized_collection(collection, group_choice_records).map { |choice|
			choice_wrapping(choice_wrapping_html_options(choice)) { # <li class="choice">
				choice_html(choice)                                   #   <label for="project_technology_ids_49">
																															#     <input type="checkbox" name="project[technology_ids][]" id="project_technology_ids_49" value="49" />AWS Route53
																															#   </label>
			}                                                       # </li>
		}.join("\n").html_safe
	end


	def choice_wrapping_html_options(choice)
		classes = ["choice", "grouped_check_boxes__choice"]
		classes << "#{sanitized_method_name.singularize}_#{choice_html_safe_value(choice)}" if value_as_class?

		{ class: classes.join(" ") }
	end


	def grouped_collection
		fail "You must provide a `:collection` input option" unless collection_from_options

		case (predicat = input_options.fetch(:group_method))
		when Proc   then collection_from_options.group_by { |record| predicat.call(record) }
		when Symbol then collection_from_options.group_by { |record| record.public_send(predicat) }
		else fail "You must provide either a Proc or a Symbol in the `:group_method` input option"
		end
	end


	# `collection` is an Array of [label, value] Arrays, so `arr_el.second` will return the <option value="">
	# `group_records` is an Array of ActiveRecord objects
	# `value_method` is a Symbol of the method name called on each record to get what to insert into the <option value="">
	#
	def normalized_collection(collection, group_records)
		collection.select do |arr_el|
			group_records
				.map(&value_method.to_sym)
				.include?(arr_el.second)
		end
	end


	def group_name(group_record_or_label)
		return "No subgroup" unless group_record_or_label

		if (label_method = input_options[:group_label_method].presence)
			group_record_or_label.public_send(label_method)
		else
			group_record_or_label
		end
	end

end

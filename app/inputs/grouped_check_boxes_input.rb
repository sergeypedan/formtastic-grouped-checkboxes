# frozen_string_literal: true

class GroupedCheckBoxesInput < Formtastic::Inputs::CheckBoxesInput

	# Without it, the `input_wrapping()` would return
	# => "<li class=\"grouped_check_boxes input optional\" >...</li>"
	#
	# but we want to reuse existing CSS from regular checkboxes
	# and for that we want to preserve the .check_boxes instead of .grouped_check_boxes
	#
	# Look into `Formtastic::Inputs::Base::Naming#as`
	#
	def self.name
		"CheckBoxesInput"
	end

	def grouped_collection
		fail "You must provide a `:collection` input option" unless collection_from_options

		case (predicat = input_options.fetch(:group_by))
		when Proc   then collection_from_options.group_by { |record| predicat.call(record) }
		when Symbol then collection_from_options.group_by { |record| record.public_send(predicat) }
		else fail "You must provide either a Proc or a Symbol in the `:group_by` input option"
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

	def group_label(group_record_or_label)
		return unless group_record_or_label

		if (label_method = input_options[:group_label].presence)
			group_record_or_label.public_send(label_method)
		else
			group_record_or_label
		end
	end

	def group_header_html(group_record_or_label)
		template.content_tag :h4, group_label(group_record_or_label)
	end

	# @return [String] of concatenated <li>s
	def choices_group_contents
		grouped_collection.
		map { |group_method_call_return_value, group_choice_records|
			[
				group_header_html(group_method_call_return_value),
				# ActiveRecord most probably

				normalized_collection(collection, group_choice_records).map { |choice|
					choice_wrapping(choice_wrapping_html_options(choice)) { # <li class="choice">
						choice_html(choice)                                   #   <label for="project_technology_ids_49">
						                                                      #     <input type="checkbox" name="project[technology_ids][]" id="project_technology_ids_49" value="49" />AWS Route53
						                                                      #   </label>
					}                                                       # </li>
				}
			].join("\n")

		}.join("\n").html_safe
	end


	def li_with_checkboxes
		choices_group_wrapping do # <ol class="choices-group">
			choices_group_contents
		end # </ol>
	end

	# legend_html          => "<legend class=\"label\"><label>Technologies</label></legend>"
	# hidden_field_for_all => "<input type=\"hidden\" name=\"project[technology_ids][]\" id=\"project_technologies_none\" value=\"\" autocomplete=\"off\" />"
	def to_html
		input_wrapping do  # => "<li class=\"grouped_check_boxes input optional\" id=\"project_technologies_input\">\n\n</li>"
			choices_wrapping do  # => "<fieldset class=\"choices\"></fieldset>"
				legend_html << hidden_field_for_all << li_with_checkboxes
			end
		end
	end

end

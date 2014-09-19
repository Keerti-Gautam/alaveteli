class AdminPublicBodyCategoryController < AdminController
    def index
        @locale = self.locale_from_params
        @category_headings = PublicBodyHeading.all
        @without_heading = PublicBodyCategory.without_headings
    end

    def new
        @category = PublicBodyCategory.new
        render :formats => [:html]
    end

    def edit
        @category = PublicBodyCategory.find(params[:id])
        @tagged_public_bodies = PublicBody.find_by_tag(@category.category_tag)
    end

    def update
        @category = PublicBodyCategory.find(params[:id])
        @tagged_public_bodies = PublicBody.find_by_tag(@category.category_tag)
        heading_ids = []

        I18n.with_locale(I18n.default_locale) do
            if params[:public_body_category][:category_tag] && PublicBody.find_by_tag(@category.category_tag).count > 0 && @category.category_tag != params[:public_body_category][:category_tag]
                flash[:notice] = 'There are authorities associated with this category, so the tag can\'t be renamed'
            else
                if params[:headings]
                    heading_ids = params[:headings].values
                    removed_headings = @category.public_body_heading_ids - heading_ids
                    added_headings = heading_ids - @category.public_body_heading_ids

                    unless removed_headings.empty?
                        # remove the link objects
                        deleted_links = PublicBodyCategoryLink.where(
                            :public_body_category_id => @category.id,
                            :public_body_heading_id => [removed_headings]
                        )
                        deleted_links.delete_all

                        #fix the category object
                        @category.public_body_heading_ids = heading_ids
                    end

                    added_headings.each do |heading_id|
                        @category.add_to_heading(PublicBodyHeading.find(heading_id))
                    end
                end

                if @category.update_attributes(params[:public_body_category])
                    flash[:notice] = 'Category was successfully updated.'
                end
            end

            render :action => 'edit'
        end
    end

    def reorder
        error = nil
        ActiveRecord::Base.transaction do
            params[:categories].each_with_index do |category_id, index|
                link = PublicBodyCategoryLink.find(:first,
                                                  :conditions => ['public_body_category_id = ?
                                                                   AND public_body_heading_id = ?',
                                                                   category_id, params[:heading_id]])
                unless link
                    error = "Couldn't find PublicBodyCategoryLink for category #{category_id}, heading #{params[:heading_id]}"
                    raise ActiveRecord::Rollback
                end
                link.category_display_order = index
                unless link.save
                    error = link.errors.full_messages.join(",")
                    raise ActiveRecord::Rollback
                end
            end
            render :nothing => true, :status => :ok and return
        end
        render :text => error, :status => :unprocessable_entity
    end

    def create
        I18n.with_locale(I18n.default_locale) do
            @category = PublicBodyCategory.new(params[:public_body_category])
            if @category.save
                if params[:headings]
                    params[:headings].values.each do |heading_id|
                        @category.add_to_heading(PublicBodyHeading.find(heading_id))
                    end
                end
                flash[:notice] = 'Category was successfully created.'
                redirect_to admin_category_index_url
            else
                render :action => 'new'
            end
        end
    end

    def destroy
        @locale = self.locale_from_params
        I18n.with_locale(@locale) do
            category = PublicBodyCategory.find(params[:id])
            category.destroy
            flash[:notice] = "Category was successfully destroyed."
            redirect_to admin_category_index_url
        end
    end
end

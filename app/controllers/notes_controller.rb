class NotesController < ApplicationController
  before_filter :authenticate_user!

  def create
    new_note = Note.new(
      subject: user_stamp(current_user),
      note: params[:note],

      # We need to set both entity_id and contact_id in order for API chaining to work properly, this appears to be a bug in CiviCrm?
      entity_id: params[:contact_id],
      contact_id: params[:contact_id]
    )

    if new_note.save
      flash[:success] = 'Note added.'
    else
      flash[:error] = 'Oops, could not add the note!'
    end
  end

  private

  def user_stamp(user)
    # This is a hack to provide some way of identifying notes to users due to CiviCrm limitations
    if user.to_s.present? && user.to_s != user.email
      "#{ user.to_s } (#{ user.email })"
    else
      "(#{ user.email })"
    end
  end
end
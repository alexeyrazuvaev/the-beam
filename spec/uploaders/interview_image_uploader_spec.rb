require 'rails_helper'

RSpec.describe InterviewImageUploader, type: :uploader do
  describe 'validations' do
    def get_validation_messages(image_path)
      interview = FactoryGirl.build :interview, image: File.open(File.join(Rails.root, image_path))
      interview.valid?
      interview.errors.messages[:image]
    end

    context 'when valid' do
      it { expect(get_validation_messages('/spec/fixtures/300px.jpg')).to be_blank }
    end

    context 'when uppercased extension' do
      it { expect(get_validation_messages('/spec/fixtures/300px_copy.jPg')).to be_blank }
    end

    context 'when wrong format, extension, and weight' do
      it 'has proper errors messages' do
        expected_errors = [
          "isn't in allowed format (only .jpg, .png, .gif are supported)",
          'is smaller than 5 KB',
          "isn't of allowed type: [\"image/jpg\", \"image/jpeg\", \"image/png\", \"image/gif\"]"
        ]

        expect(get_validation_messages('/spec/fixtures/not_image.tsv')).to eq expected_errors
      end
    end

    context 'when wrong dimensions and weight' do
      it 'has proper errors messages' do
        expected_errors = [
          'is narrower than 150 px',
          'is shorter than 150 px',
          'is smaller than 5 KB'
        ]

        expect(get_validation_messages('/spec/fixtures/100px.jpg')).to eq expected_errors
      end
    end

    context 'when valid extension but wrong mime type' do
      it 'has proper errors messages' do
        expected_errors = [
          'is smaller than 5 KB',
          "isn't of allowed type: [\"image/jpg\", \"image/jpeg\", \"image/png\", \"image/gif\"]"
        ]

        expect(get_validation_messages('/spec/fixtures/really_tsv_but.png')).to eq expected_errors
      end
    end
  end

  describe 'processing' do
    let(:file) { File.open(File.join(Rails.root, '/spec/fixtures/300px.jpg')) }

    describe 'store with resizing' do
      it 'creates required versions' do
        interview = create(:interview, image: file)
        expect(interview.image.keys).to eq [:original, :x1200]
      end
    end

    describe 'cropping' do
      it 'creates "cropped" version' do
        interview = create(:interview, image: file)
        crop_data = %w(166 166 0 0) # [weight, height, offset_x, offset_y]

        described_class.new(:cache).crop_image(interview, crop_data)

        expect(interview.image.keys).to eq [:original, :x1200, :cropped]
      end
    end
  end
end
